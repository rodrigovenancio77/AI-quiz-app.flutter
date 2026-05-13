const admin = require("firebase-admin");
const { GoogleGenerativeAI, SchemaType } = require("@google/generative-ai");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");

admin.initializeApp();

const db = admin.firestore();
const GEMINI_SECRET = defineSecret("GEMINI_API_KEY");

/** @typedef {{ prompt: string, answers: string[], correctIndex: number }} QuizQuestion */
/** @typedef {{ title: string, topic?: string, questions: QuizQuestion[] }} QuizPayload */

const quizGenerationSchema = {
  type: SchemaType.OBJECT,
  properties: {
    title: { type: SchemaType.STRING, description: "Short descriptive quiz title" },
    topic: { type: SchemaType.STRING, description: "Theme or subject in user language" },
    questions: {
      type: SchemaType.ARRAY,
      description: "Multiple-choice questions only",
      items: {
        type: SchemaType.OBJECT,
        properties: {
          prompt: { type: SchemaType.STRING },
          answers: {
            type: SchemaType.ARRAY,
            items: { type: SchemaType.STRING },
          },
          correctIndex: {
            type: SchemaType.INTEGER,
            description: "0-based index of the correct alternative",
          },
        },
        required: ["prompt", "answers", "correctIndex"],
      },
    },
  },
  required: ["title", "questions"],
};

/**
 * Validates normalized quiz payload from Gemini or persistQuiz client.
 * @param {unknown} quiz
 * @param {number} maxQuestions
 * @returns {QuizPayload}
 */
function assertValidQuiz(quiz, maxQuestions) {
  if (!quiz || typeof quiz !== "object") {
    throw new HttpsError("invalid-argument", "Quiz payload must be an object.");
  }
  const { title, topic, questions } = quiz;
  if (typeof title !== "string" || !title.trim()) {
    throw new HttpsError("invalid-argument", "Quiz title is required.");
  }
  if (topic !== undefined && topic !== null && typeof topic !== "string") {
    throw new HttpsError("invalid-argument", "Quiz topic must be a string.");
  }
  if (!Array.isArray(questions) || questions.length === 0) {
    throw new HttpsError("invalid-argument", "Quiz must include at least one question.");
  }
  if (questions.length > maxQuestions) {
    throw new HttpsError("invalid-argument", `Too many questions (max ${maxQuestions}).`);
  }
  questions.forEach((q, i) => {
    if (!q || typeof q !== "object") {
      throw new HttpsError("invalid-argument", `Question ${i} is invalid.`);
    }
    if (typeof q.prompt !== "string" || !q.prompt.trim()) {
      throw new HttpsError("invalid-argument", `Question ${i} needs a prompt.`);
    }
    if (
      !Array.isArray(q.answers) ||
      q.answers.length !== 4 ||
      q.answers.some((a) => typeof a !== "string" || !String(a).trim())
    ) {
      throw new HttpsError("invalid-argument", `Question ${i} must have exactly 4 non-empty answers.`);
    }
    const idx = Number(q.correctIndex);
    if (!Number.isInteger(idx) || idx < 0 || idx > 3) {
      throw new HttpsError("invalid-argument", `Question ${i} correctIndex must be 0–3.`);
    }
  });
  return /** @type {QuizPayload} */ (quiz);
}

exports.generateQuiz = onCall(
  {
    secrets: [GEMINI_SECRET],
    region: "us-central1",
    timeoutSeconds: 120,
    memory: "512MiB",
  },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Sign in is required.");
    }

    const rawTopic = typeof request.data?.topic === "string" ? request.data.topic.trim() : "";
    const n = Number(request.data?.questionCount);
    const questionCount =
      Number.isFinite(n) && n > 0 ? Math.min(40, Math.max(1, Math.floor(n))) : 10;

    if (!rawTopic) {
      throw new HttpsError("invalid-argument", "Topic is required.");
    }

    const apiKey = GEMINI_SECRET.value();
    if (!apiKey) {
      throw new HttpsError(
        "failed-precondition",
        "Missing GEMINI_API_KEY secret for this deployment.",
      );
    }

    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({
      model: "gemini-1.5-flash",
      generationConfig: {
        responseMimeType: "application/json",
        responseSchema: quizGenerationSchema,
        temperature: 0.6,
      },
    });

    const userPrompt =
      `Create a quiz in Portuguese (Brazil) about the following topic (keep content accurate):\n"${rawTopic}"\n\n` +
      `Requirements:\n` +
      `- Exactly ${questionCount} questions.\n` +
      `- Each question: one clear stem, exactly 4 plausible alternatives, exactly one correctIndex (0-3).\n` +
      `- Title: short and engaging.\n` +
      `- topic field should echo or refine the user's theme briefly.\n` +
      `- No Markdown in JSON fields; plain text only.`;

    try {
      const result = await model.generateContent(userPrompt);
      const text = result.response.text();
      /** @type {unknown} */
      const parsed = JSON.parse(text || "{}");
      const quiz = assertValidQuiz(parsed, 40);

      const expectedLen = quiz.questions.length;
      if (expectedLen !== questionCount) {
        throw new HttpsError(
          "internal",
          `Model returned ${expectedLen} questions but ${questionCount} were requested.`,
        );
      }

      quiz.topic =
        quiz.topic !== undefined && quiz.topic !== null
          ? String(quiz.topic).trim() || rawTopic
          : rawTopic;

      return { quiz };
    } catch (e) {
      if (e instanceof HttpsError) {
        throw e;
      }
      console.error("generateQuiz error", e);
      throw new HttpsError(
        "internal",
        `Quiz generation failed: ${e.message || String(e)}`,
      );
    }
  },
);

exports.persistQuiz = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 30,
    memory: "256MiB",
  },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Sign in is required.");
    }

    const quiz = assertValidQuiz(request.data?.quiz, 40);
    quiz.title = quiz.title.trim();
    if (quiz.topic) quiz.topic = String(quiz.topic).trim();

    const ref = db.collection("quizzes").doc();
    const now = admin.firestore.FieldValue.serverTimestamp();

    await ref.set({
      ownerUid: request.auth.uid,
      title: quiz.title,
      topic: quiz.topic || null,
      questions: quiz.questions.map((q) => ({
        prompt: q.prompt.trim(),
        answers: q.answers.map((a) => String(a).trim()),
        correctIndex: q.correctIndex,
      })),
      createdAt: now,
      updatedAt: now,
      source: "ai_generated_or_edited",
    });

    return { quizId: ref.id };
  },
);

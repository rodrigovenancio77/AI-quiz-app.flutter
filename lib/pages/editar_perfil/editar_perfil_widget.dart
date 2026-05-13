import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// --- NOVOS IMPORTS PARA AUTENTICAÇÃO ---
import '/auth/firebase_auth/auth_util.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'editar_perfil_model.dart';
export 'editar_perfil_model.dart';

class EditarPerfilWidget extends StatefulWidget {
  const EditarPerfilWidget({super.key});

  static String routeName = 'EditarPerfil';
  static String routePath = '/editarPerfil';

  @override
  State<EditarPerfilWidget> createState() => _EditarPerfilWidgetState();
}

class _EditarPerfilWidgetState extends State<EditarPerfilWidget> {
  late EditarPerfilModel _model;
  
  // Variável de estado para controlar a visibilidade dos campos de password
  bool _showPasswordFields = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditarPerfilModel());

    // --- PREENCHER CAIXAS COM DADOS DO UTILIZADOR ---
    _model.textController1 ??= TextEditingController(text: currentUserDisplayName);
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController(text: currentUserEmail);
    _model.textFieldFocusNode2 ??= FocusNode();

    // Palavras-passe ficam vazias por defeito
    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFEBEBF0),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Editar Perfil',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  ),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 22.0,
                ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView( 
            padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- IMAGEM DO UTILIZADOR ---
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150.0,
                      height: 150.0,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image.network(
                        currentUserPhoto.isNotEmpty
                            ? currentUserPhoto
                            : 'https://images.unsplash.com/photo-1562788869-4ed32648eb72?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHw2fHxwcm9mZXNzb3J8ZW58MHx8fHwxNzc3MjM5ODQ3fDA&ixlib=rb-4.1.0&q=80&w=400',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                Form(
                  key: _model.formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // --- NOME ---
                      TextFormField(
                        controller: _model.textController1,
                        focusNode: _model.textFieldFocusNode1,
                        decoration: _buildInputDecoration(context, 'Nome', FontAwesomeIcons.pencilAlt),
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              font: GoogleFonts.inter(),
                              color: const Color(0xFF9095A1),
                            ),
                        validator: _model.textController1Validator.asValidator(context),
                      ),
                      
                      const SizedBox(height: 12.0),

                      // --- EMAIL ---
                      TextFormField(
                        controller: _model.textController2,
                        focusNode: _model.textFieldFocusNode2,
                        decoration: _buildInputDecoration(context, 'Email', Icons.alternate_email),
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              font: GoogleFonts.inter(),
                              color: const Color(0xFF9095A1),
                            ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _model.textController2Validator.asValidator(context),
                      ),
                      
                      const SizedBox(height: 12.0),

                      // --- SECÇÃO DE PALAVRA-PASSE ---
                      if (!_showPasswordFields)
                        FFButtonWidget(
                          onPressed: () => setState(() => _showPasswordFields = true),
                          text: 'Alterar Palavra-Passe',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 40.0,
                            color: Colors.transparent,
                            textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                  color: const Color(0xFF42436F),
                                ),
                            borderSide: const BorderSide(color: Color(0xFF42436F), width: 1.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        )
                      else ...[
                        // Palavra-Passe Nova
                        TextFormField(
                          controller: _model.textController3,
                          focusNode: _model.textFieldFocusNode3,
                          obscureText: !_model.passwordVisibility1,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Nova Palavra-Passe',
                            hintStyle: FlutterFlowTheme.of(context).labelMedium,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFF9095A1), width: 1.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: InkWell(
                              onTap: () => setState(() =>
                                  _model.passwordVisibility1 = !_model.passwordVisibility1),
                              child: Icon(
                                _model.passwordVisibility1
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFFAAAEB8),
                                size: 20.0,
                              ),
                            ),
                          ),
                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                                font: GoogleFonts.inter(),
                                color: const Color(0xFF9095A1),
                              ),
                        ),
                        
                        const SizedBox(height: 12.0),

                        // Confirmar Palavra-Passe
                        TextFormField(
                          controller: _model.textController4,
                          focusNode: _model.textFieldFocusNode4,
                          obscureText: !_model.passwordVisibility2,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Confirmar Nova Palavra-Passe',
                            hintStyle: FlutterFlowTheme.of(context).labelMedium,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFF9095A1), width: 1.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: InkWell(
                              onTap: () => setState(() =>
                                  _model.passwordVisibility2 = !_model.passwordVisibility2),
                              child: Icon(
                                _model.passwordVisibility2
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFFAAAEB8),
                                size: 20.0,
                              ),
                            ),
                          ),
                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                                font: GoogleFonts.inter(),
                                color: const Color(0xFF9095A1),
                              ),
                        ),
                      ],
                      
                      const SizedBox(height: 24.0),
                      
                      // --- BOTOES DE AÇÃO: CANCELAR E GUARDAR ---
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FFButtonWidget(
                            onPressed: () async {
                              context.safePop();
                            },
                            text: 'Cancelar',
                            options: FFButtonOptions(
                              width: 150.0,
                              height: 40.0,
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.interTight(),
                                    color: FlutterFlowTheme.of(context).alternate,
                                  ),
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          FFButtonWidget(
                            onPressed: () async {
                              await _guardarAlteracoes();
                            },
                            text: 'Guardar',
                            options: FFButtonOptions(
                              width: 150.0,
                              height: 40.0,
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.interTight(),
                                    color: Colors.white,
                                  ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24.0),
                      
                      // --- BOTÃO DE LOGOUT ---
                      FFButtonWidget(
                        onPressed: () async {
                          await authManager.signOut();
                          if (context.mounted) context.go('/authentication');
                        },
                        text: 'Sair da Conta',
                        icon: const Icon(Icons.logout_rounded, size: 18.0),
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 40.0,
                          color: const Color(0xFFE0E0E0),
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.interTight(),
                                color: Colors.black,
                              ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),

                      const SizedBox(height: 12.0),

                      // --- BOTÃO DESATIVAR CONTA ---
                      FFButtonWidget(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (alertDialogContext) {
                              return AlertDialog(
                                title: const Text('Desativar Conta'),
                                content: const Text('Tem a certeza que deseja apagar a sua conta? Esta ação é irreversível.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(alertDialogContext, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(alertDialogContext, true),
                                    child: const Text('Apagar', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          ) ?? false;

                          if (confirm) {
                            await authManager.deleteUser(context);
                            if (context.mounted) context.go('/authentication');
                          }
                        },
                        text: 'Desativar Conta',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 40.0,
                          color: FlutterFlowTheme.of(context).error,
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.interTight(),
                                color: Colors.white,
                              ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper para o visual das caixas de texto
  InputDecoration _buildInputDecoration(BuildContext context, String hint, IconData icon) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: FlutterFlowTheme.of(context).labelMedium,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF9095A1), width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: Icon(icon, color: const Color(0xFFAAAEB8), size: 20.0),
    );
  }

  // --- LÓGICA DE GUARDAR ALTERAÇÕES NO FIREBASE ---
  Future<void> _guardarAlteracoes() async {
    if (_model.formKey.currentState == null || !_model.formKey.currentState!.validate()) {
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        bool updated = false;

        // 1. Atualizar Nome
        if (_model.textController1!.text != currentUserDisplayName) {
          await user.updateDisplayName(_model.textController1!.text);
          updated = true;
        }

        // 2. Atualizar Email
        if (_model.textController2!.text != currentUserEmail) {
          await authManager.updateEmail(
            email: _model.textController2!.text,
            context: context,
          );
          updated = true;
        }

        // 3. Atualizar Password (se os campos estiverem visíveis e preenchidos)
        if (_showPasswordFields && _model.textController3!.text.isNotEmpty) {
          if (_model.textController3!.text == _model.textController4!.text) {
            await authManager.updatePassword(
              newPassword: _model.textController3!.text,
              context: context,
            );
            updated = true;
            
            // Esconde os campos novamente após alterar a password
            setState(() {
              _showPasswordFields = false;
              _model.textController3!.clear();
              _model.textController4!.clear();
            });
          } else {
            if (mounted) showSnackbar(context, 'As palavras-passe não coincidem.');
            return;
          }
        }

        if (mounted) {
          if (updated) {
            showSnackbar(context, 'Perfil atualizado com sucesso!');
            setState(() {}); 
          } else {
            showSnackbar(context, 'Nenhuma alteração foi feita.');
          }
        }
      }
    } catch (e) {
      if (mounted) showSnackbar(context, 'Erro ao guardar: $e');
    }
  }
}
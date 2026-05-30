import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/firebase_auth/auth_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

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

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isGoogleUser = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditarPerfilModel());

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _isGoogleUser = user.providerData.any((provider) => provider.providerId == 'google.com');
    }

    _model.textController1 ??= TextEditingController(text: currentUserDisplayName);
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController(text: currentUserEmail);
    _model.textFieldFocusNode2 ??= FocusNode();

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

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Câmara'),
                onTap: () {
                  Navigator.pop(context);
                  _model.pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _model.pickImage(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed('Dashboard');
              }
            },
          ),
          title: Text(
            'Editar Perfil',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
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
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: const AlignmentDirectional(1.0, 1.0),
                      children: [
                        Container(
                          width: 120.0,
                          height: 120.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).alternate,
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60.0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (_model.pickedImageBytes != null)
                                  Image.memory(
                                    _model.pickedImageBytes!,
                                    width: 120.0,
                                    height: 120.0,
                                    fit: BoxFit.cover,
                                  ),
                                if (_model.pickedImageBytes == null)
                                  Image.network(
                                    currentUserPhoto.isNotEmpty ? currentUserPhoto : 'https://picsum.photos/seed/user/200',
                                    width: 120.0,
                                    height: 120.0,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: FlutterFlowTheme.of(context).alternate,
                                        child: Icon(Icons.person, color: FlutterFlowTheme.of(context).secondaryText, size: 60.0),
                                      );
                                    },
                                  ),
                                if (_model.isUploading)
                                  Container(
                                    color: Colors.black45,
                                    child: CircularProgressIndicator(color: FlutterFlowTheme.of(context).primary),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 30.0,
                          borderWidth: 1.0,
                          buttonSize: 40.0,
                          fillColor: FlutterFlowTheme.of(context).primary,
                          icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20.0),
                          onPressed: () => _showImageSourceSheet(context),
                        ),
                      ],
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
                      TextFormField(
                        controller: _model.textController1,
                        focusNode: _model.textFieldFocusNode1,
                        decoration: _buildInputDecoration(context, 'Nome Exibido', Icons.edit),
                        style: FlutterFlowTheme.of(context).bodyLarge.override(font: GoogleFonts.inter(), color: const Color(0xFF9095A1)),
                        validator: _model.textController1Validator.asValidator(context),
                      ),
                      const SizedBox(height: 12.0),

                      TextFormField(
                        controller: _model.textController2,
                        focusNode: _model.textFieldFocusNode2,
                        readOnly: _isGoogleUser,
                        enabled: !_isGoogleUser,
                        decoration: _buildInputDecoration(context, 'Endereço de Email', Icons.alternate_email),
                        style: FlutterFlowTheme.of(context).bodyLarge.override(font: GoogleFonts.inter(), color: const Color(0xFF9095A1)),
                        keyboardType: TextInputType.emailAddress,
                        validator: _model.textController2Validator.asValidator(context),
                      ),
                      const SizedBox(height: 12.0),

                      if (!_isGoogleUser) ...[
                        TextFormField(
                          controller: _model.textController3,
                          focusNode: _model.textFieldFocusNode3,
                          obscureText: !_model.passwordVisibility1,
                          decoration: _buildPasswordDecoration(
                            context, 
                            'Nova Palavra-Passe', 
                            _model.passwordVisibility1, 
                            () => setState(() => _model.passwordVisibility1 = !_model.passwordVisibility1)
                          ),
                          style: FlutterFlowTheme.of(context).bodyLarge.override(font: GoogleFonts.inter(), color: const Color(0xFF9095A1)),
                        ),
                        const SizedBox(height: 12.0),

                        TextFormField(
                          controller: _model.textController4,
                          focusNode: _model.textFieldFocusNode4,
                          obscureText: !_model.passwordVisibility2,
                          decoration: _buildPasswordDecoration(
                            context, 
                            'Confirmar Nova Palavra-Passe', 
                            _model.passwordVisibility2, 
                            () => setState(() => _model.passwordVisibility2 = !_model.passwordVisibility2)
                          ),
                          style: FlutterFlowTheme.of(context).bodyLarge.override(font: GoogleFonts.inter(), color: const Color(0xFF9095A1)),
                        ),
                        const SizedBox(height: 24.0),
                      ] else ...[
                        const SizedBox(height: 12.0),
                      ],
                      
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FFButtonWidget(
                            onPressed: () async {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.goNamed('Dashboard');
                              }
                            },
                            text: 'Cancelar',
                            options: FFButtonOptions(
                              width: 150.0,
                              height: 40.0,
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(font: GoogleFonts.interTight(), color: FlutterFlowTheme.of(context).alternate),
                              borderSide: BorderSide(color: FlutterFlowTheme.of(context).alternate),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          FFButtonWidget(
                            onPressed: _model.isUploading ? null : () async {
                              await _guardarAlteracoes();
                            },
                            text: _model.isUploading ? 'Aguarde...' : 'Guardar',
                            options: FFButtonOptions(
                              width: 150.0,
                              height: 40.0,
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(font: GoogleFonts.interTight(), color: Colors.white),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32.0),
                      
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
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(font: GoogleFonts.interTight(), color: Colors.black),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),

                      const SizedBox(height: 12.0),

                      FFButtonWidget(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (alertDialogContext) {
                              return AlertDialog(
                                title: const Text('Desativar Conta'),
                                content: const Text('Tem a certeza que deseja apagar a sua conta? Esta ação é irreversível.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(alertDialogContext, false), child: const Text('Cancelar')),
                                  TextButton(onPressed: () => Navigator.pop(alertDialogContext, true), child: const Text('Apagar', style: TextStyle(color: Colors.red))),
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
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(font: GoogleFonts.interTight(), color: Colors.white),
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

  InputDecoration _buildInputDecoration(BuildContext context, String hint, IconData icon) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: FlutterFlowTheme.of(context).labelMedium,
      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF9095A1), width: 1.0), borderRadius: BorderRadius.circular(12.0)),
      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0x00000000), width: 1.0), borderRadius: BorderRadius.circular(12.0)),
      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.0), borderRadius: BorderRadius.circular(12.0)),
      focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.0), borderRadius: BorderRadius.circular(12.0)),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: Icon(icon, color: const Color(0xFFAAAEB8), size: 20.0),
    );
  }

  InputDecoration _buildPasswordDecoration(BuildContext context, String hint, bool isVisible, VoidCallback toggleVisibility) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: FlutterFlowTheme.of(context).labelMedium,
      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF9095A1), width: 1.0), borderRadius: BorderRadius.circular(12.0)),
      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0x00000000), width: 1.0), borderRadius: BorderRadius.circular(12.0)),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: InkWell(
        onTap: toggleVisibility,
        child: Icon(isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFFAAAEB8), size: 20.0),
      ),
    );
  }

  Future<void> _guardarAlteracoes() async {
    setState(() => _model.isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        bool updated = false;
        String? newPhotoUrl;

        // 1. Upload Imagem
        if (_model.pickedImageBytes != null) {
          newPhotoUrl = await _model.uploadToImageBB();
          if (newPhotoUrl != null) {
            await user.updatePhotoURL(newPhotoUrl);
            updated = true;
          }
        }

        // 2. Atualizar Nome
        if (_model.textController1!.text.isNotEmpty && _model.textController1!.text != currentUserDisplayName) {
          await user.updateDisplayName(_model.textController1!.text);
          updated = true;
        }

        // 3. Atualizar Email
        if (_model.textController2!.text.isNotEmpty && _model.textController2!.text != currentUserEmail) {
          bool emailSuccess = await authManager.updateEmail(email: _model.textController2!.text, context: context);
          if (emailSuccess) {
            updated = true;
          } else {
            setState(() => _model.isUploading = false);
            return;
          }
        }

        bool passwordChanged = false;

        // 4. Atualizar Password
        if (_model.textController3!.text.isNotEmpty) {
          if (_model.textController3!.text == _model.textController4!.text) {
            bool passSuccess = await authManager.updatePassword(newPassword: _model.textController3!.text, context: context);
            if (passSuccess) {
              updated = true;
              passwordChanged = true;
              _model.textController3!.clear();
              _model.textController4!.clear();
            } else {
              setState(() => _model.isUploading = false);
              return;
            }
          } else {
            if (mounted) showSnackbar(context, 'As palavras-passe não coincidem.');
            setState(() => _model.isUploading = false);
            return;
          }
        }

        // --- CORREÇÃO DO INSTANT REFRESH ---
        if (updated) {
          await user.reload();
        }

        if (mounted) {
          if (passwordChanged) {
            showSnackbar(context, 'Palavra-passe alterada. Inicia sessão novamente.');
            await authManager.signOut();
            context.go('/authentication');
          } else if (updated) {
            showSnackbar(context, 'Perfil atualizado com sucesso!');
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('Dashboard'); // Rota segura de salvaguarda
            }
          } else {
            showSnackbar(context, 'Nenhuma alteração foi feita.');
          }
        }
      }
    } catch (e) {
      if (mounted) showSnackbar(context, 'Erro ao guardar: $e');
    } finally {
      if (mounted) setState(() => _model.isUploading = false);
    }
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/suit_widgets.dart';
import '../services/storage_service.dart';
import '../services/game_state.dart';

class ConfigScreen extends StatefulWidget {
  final GameState gameState;

  const ConfigScreen({super.key, required this.gameState});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  late TextEditingController _ctrl1;
  late TextEditingController _ctrl2;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl1 = TextEditingController();
    _ctrl2 = TextEditingController();
    _loadNames();
  }

  Future<void> _loadNames() async {
    final t1 = await StorageService.getTeam1Name();
    final t2 = await StorageService.getTeam2Name();
    setState(() {
      _ctrl1.text = t1;
      _ctrl2.text = t2;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final t1 = _ctrl1.text.trim();
    final t2 = _ctrl2.text.trim();
    if (t1.isEmpty || t2.isEmpty) {
      _showSnack('Os nomes não podem ser vazios!', isError: true);
      return;
    }
    setState(() => _saving = true);
    await StorageService.saveTeamNames(t1, t2);
    await widget.gameState.loadTeamNames();
    setState(() => _saving = false);
    if (mounted) {
      _showSnack('Configurações salvas!');
      Navigator.pop(context);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.lato()),
      backgroundColor:
          isError ? TruckiColors.red : TruckiColors.gold.withOpacity(0.85),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TruckiColors.black,
      body: Stack(
        children: [
          _buildBg(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                if (_loading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: TruckiColors.gold),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const SuitRow(size: 18, opacity: 0.4),
                          const SizedBox(height: 32),
                          _sectionLabel('EQUIPE 1'),
                          const SizedBox(height: 12),
                          _teamField(
                            controller: _ctrl1,
                            suit: '♠',
                            suitColor: TruckiColors.suitBlack,
                            hint: 'Ex: Nós',
                          ),
                          const SizedBox(height: 28),
                          _sectionLabel('EQUIPE 2'),
                          const SizedBox(height: 12),
                          _teamField(
                            controller: _ctrl2,
                            suit: '♥',
                            suitColor: TruckiColors.red,
                            hint: 'Ex: Eles',
                          ),
                          const SizedBox(height: 40),
                          const GoldDivider(),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: _OutlineBtn(
                                  label: 'PADRÃO',
                                  onTap: () {
                                    setState(() {
                                      _ctrl1.text = 'Nós';
                                      _ctrl2.text = 'Eles';
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: _GoldBtn(
                                  label: _saving ? 'SALVANDO...' : 'SALVAR',
                                  onTap: _saving ? null : _save,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBg() {
    return Positioned.fill(
      child: Stack(children: [
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                TruckiColors.gold.withOpacity(0.05),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: TruckiColors.gold, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'CONFIGURAÇÕES',
            style: GoogleFonts.playfairDisplay(
              color: TruckiColors.gold,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Text('♦',
                style: TextStyle(color: TruckiColors.gold, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: TruckiColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.lato(
            color: TruckiColors.gold,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  Widget _teamField({
    required TextEditingController controller,
    required String suit,
    required Color suitColor,
    required String hint,
  }) {
    return LuxCard(
      borderColor: suitColor,
      borderOpacity: 0.3,
      child: Row(
        children: [
          Text(
            suit,
            style: TextStyle(
              fontSize: 28,
              color: suitColor,
              shadows: [Shadow(color: suitColor.withOpacity(0.4), blurRadius: 8)],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: 18,
              style: GoogleFonts.playfairDisplay(
                color: TruckiColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.playfairDisplay(
                    color: TruckiColors.textMuted.withOpacity(0.5)),
                counterStyle: GoogleFonts.lato(
                    color: TruckiColors.textMuted, fontSize: 10),
                border: InputBorder.none,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: suitColor.withOpacity(0.3), width: 1),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: suitColor, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: TruckiColors.textMuted.withOpacity(0.3), width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.lato(
            color: TruckiColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _GoldBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _GoldBtn({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: onTap == null
                ? [TruckiColors.textMuted, TruckiColors.textMuted]
                : [TruckiColors.gold, TruckiColors.goldDark],
          ),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: TruckiColors.gold.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.lato(
            color: TruckiColors.black,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/suit_widgets.dart';
import '../services/game_state.dart';

class InGameScreen extends StatefulWidget {
  final GameState gameState;

  const InGameScreen({super.key, required this.gameState});

  @override
  State<InGameScreen> createState() => _InGameScreenState();
}

class _InGameScreenState extends State<InGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulse1;
  late AnimationController _pulse2;
  late Animation<double> _scale1;
  late Animation<double> _scale2;
  bool _winnerShown = false;

  GameState get gs => widget.gameState;

  @override
  void initState() {
    super.initState();
    _pulse1 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _pulse2 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _scale1 = Tween<double>(begin: 1, end: 1.18)
        .animate(CurvedAnimation(parent: _pulse1, curve: Curves.easeOut));
    _scale2 = Tween<double>(begin: 1, end: 1.18)
        .animate(CurvedAnimation(parent: _pulse2, curve: Curves.easeOut));

    gs.addListener(_onStateChange);
  }

  @override
  void dispose() {
    gs.removeListener(_onStateChange);
    _pulse1.dispose();
    _pulse2.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (!mounted) return;
    setState(() {});
    if (gs.hasWinner && !_winnerShown) {
      _winnerShown = true;
      Future.delayed(const Duration(milliseconds: 300), _showWinnerDialog);
    }
  }

  void _onScore(int team, int delta) {
    gs.changeScore(team, delta);
    if (team == 1) {
      _pulse1.forward(from: 0);
    } else {
      _pulse2.forward(from: 0);
    }
  }

  void _showWinnerDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => _WinnerDialog(
        winner: gs.winner ?? '',
        onMenu: () async {
          await gs.finishAndSave();
          if (mounted) {
            Navigator.pop(context); // close dialog
            Navigator.pop(context); // back to menu
          }
        },
        onRestart: () async {
          await gs.finishAndSave(restart: true);
          _winnerShown = false;
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _confirmRestart() {
    showDialog(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        title: 'Reiniciar partida?',
        message:
            'O placar atual será salvo no histórico e os pontos reiniciados.',
        confirmLabel: 'REINICIAR',
        confirmColor: TruckiColors.red,
        onConfirm: () async {
          Navigator.pop(ctx);
          await gs.finishAndSave(restart: true);
          _winnerShown = false;
          setState(() {});
        },
      ),
    );
  }

  void _confirmBack() {
    // No need to show dialog — state persists, just navigate back
    Navigator.pop(context);
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
                _buildNavBar(),
                const SizedBox(height: 8),
                _buildScoreHeader(),
                const SizedBox(height: 16),
                Expanded(child: _buildScoreArea()),
                const SizedBox(height: 16),
                _buildDotProgress(),
                const SizedBox(height: 24),
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
          top: -40,
          left: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                TruckiColors.red.withOpacity(0.06),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          right: -40,
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

  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: TruckiColors.gold.withOpacity(0.15), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back to menu
          _NavBtn(
            icon: Icons.home_rounded,
            label: 'Menu',
            onTap: _confirmBack,
          ),
          const Spacer(),
          // Match title
          Column(
            children: [
              Text(
                'EM JOGO',
                style: GoogleFonts.lato(
                  color: TruckiColors.gold,
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              const SuitRow(size: 12, opacity: 0.5),
            ],
          ),
          const Spacer(),
          // Restart
          _NavBtn(
            icon: Icons.refresh_rounded,
            label: 'Reiniciar',
            color: TruckiColors.red.withOpacity(0.8),
            onTap: _confirmRestart,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'PRIMEIRO A ${GameState.maxScore} PONTOS',
            style: GoogleFonts.lato(
              color: TruckiColors.textMuted,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          Text(
            '${gs.score1} × ${gs.score2}',
            style: GoogleFonts.playfairDisplay(
              color: TruckiColors.gold.withOpacity(0.6),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _ScorePanel(
              teamName: gs.team1Name,
              score: gs.score1,
              suit: '♠',
              suitColor: TruckiColors.suitBlack,
              accentColor: TruckiColors.gold,
              scaleAnim: _scale1,
              onAdd: () => _onScore(1, 1),
              onSub: () => _onScore(1, -1),
            ),
          ),
          _VsDivider(),
          Expanded(
            child: _ScorePanel(
              teamName: gs.team2Name,
              score: gs.score2,
              suit: '♥',
              suitColor: TruckiColors.red,
              accentColor: TruckiColors.red,
              scaleAnim: _scale2,
              onAdd: () => _onScore(2, 1),
              onSub: () => _onScore(2, -1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Team 1 dots (left to right)
          ...List.generate(
            GameState.maxScore,
            (i) => _Dot(
              filled: i < gs.score1,
              color: TruckiColors.gold,
            ),
          ),
          const Spacer(),
          // Team 2 dots (right to left)
          ...List.generate(
            GameState.maxScore,
            (i) => _Dot(
              filled: i < gs.score2,
              color: TruckiColors.red,
            ),
          ).reversed.toList(),
        ],
      ),
    );
  }
}

// ── Stateless sub-widgets ────────────────────────────────────────────

class _ScorePanel extends StatelessWidget {
  final String teamName;
  final int score;
  final String suit;
  final Color suitColor;
  final Color accentColor;
  final Animation<double> scaleAnim;
  final VoidCallback onAdd;
  final VoidCallback onSub;

  const _ScorePanel({
    required this.teamName,
    required this.score,
    required this.suit,
    required this.suitColor,
    required this.accentColor,
    required this.scaleAnim,
    required this.onAdd,
    required this.onSub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.2), width: 1),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accentColor.withOpacity(0.08),
            TruckiColors.blackCard.withOpacity(0.6),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Team name
          Text(
            suit,
            style: TextStyle(
              fontSize: 20,
              color: suitColor,
              shadows: [
                Shadow(color: suitColor.withOpacity(0.5), blurRadius: 10)
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            teamName.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.playfairDisplay(
              color: TruckiColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),

          // Add button
          _ScoreBtn(
            icon: Icons.add_circle_rounded,
            color: accentColor,
            size: 44,
            onTap: onAdd,
          ),
          const SizedBox(height: 16),

          // Score number
          ScaleTransition(
            scale: scaleAnim,
            child: Text(
              '$score',
              style: GoogleFonts.playfairDisplay(
                color: TruckiColors.textPrimary,
                fontSize: 72,
                fontWeight: FontWeight.w800,
                height: 1,
                shadows: [
                  Shadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Subtract button
          _ScoreBtn(
            icon: Icons.remove_circle_rounded,
            color: score > 0
                ? accentColor.withOpacity(0.55)
                : TruckiColors.blackBorder,
            size: 36,
            onTap: onSub,
          ),
        ],
      ),
    );
  }
}

class _ScoreBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _ScoreBtn({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color, size: size),
    );
  }
}

class _VsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 1,
            height: 60,
            color: TruckiColors.gold.withOpacity(0.15),
          ),
          const SizedBox(height: 8),
          Text(
            'VS',
            style: GoogleFonts.playfairDisplay(
              color: TruckiColors.gold.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 1,
            height: 60,
            color: TruckiColors.gold.withOpacity(0.15),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool filled;
  final Color color;

  const _Dot({required this.filled, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : color.withOpacity(0.12),
        boxShadow: filled
            ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)]
            : null,
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _NavBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? TruckiColors.gold;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.lato(
                color: c,
                fontSize: 9,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dialogs ──────────────────────────────────────────────────────────

class _WinnerDialog extends StatelessWidget {
  final String winner;
  final VoidCallback onMenu;
  final VoidCallback onRestart;

  const _WinnerDialog({
    required this.winner,
    required this.onMenu,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1400), Color(0xFF0A0A0A)],
          ),
          border: Border.all(
              color: TruckiColors.gold.withOpacity(0.55), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: TruckiColors.gold.withOpacity(0.18),
              blurRadius: 40,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '♠ ♥ ♦ ♣',
              style: TextStyle(
                fontSize: 22,
                color: TruckiColors.gold.withOpacity(0.7),
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'VITÓRIA!',
              style: GoogleFonts.playfairDisplay(
                color: TruckiColors.gold,
                fontSize: 13,
                letterSpacing: 6,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              winner.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                color: TruckiColors.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'chegou a ${GameState.maxScore} pontos!',
              style: GoogleFonts.lato(
                color: TruckiColors.textMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 30),
            const GoldDivider(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TruckiColors.gold,
                  foregroundColor: TruckiColors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: GoogleFonts.lato(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    fontSize: 13,
                  ),
                ),
                child: const Text('VOLTAR AO MENU'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRestart,
                style: OutlinedButton.styleFrom(
                  foregroundColor: TruckiColors.textPrimary,
                  side: BorderSide(
                      color: TruckiColors.textMuted.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: GoogleFonts.lato(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    fontSize: 12,
                  ),
                ),
                child: const Text('JOGAR NOVAMENTE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: TruckiColors.blackCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: TruckiColors.gold.withOpacity(0.2)),
      ),
      title: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          color: TruckiColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        message,
        style: GoogleFonts.lato(color: TruckiColors.textMuted, fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('CANCELAR',
              style: GoogleFonts.lato(
                  color: TruckiColors.textMuted, letterSpacing: 1)),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(confirmLabel,
              style: GoogleFonts.lato(
                  fontWeight: FontWeight.w700, letterSpacing: 1)),
        ),
      ],
    );
  }
}

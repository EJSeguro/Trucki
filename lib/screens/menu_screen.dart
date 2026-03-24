import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/suit_widgets.dart';
import '../services/game_state.dart';
import 'in_game_screen.dart';
import 'historic_screen.dart';
import 'config_screen.dart';

class MenuScreen extends StatelessWidget {
  final GameState gameState;

  const MenuScreen({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TruckiColors.black,
      body: Stack(
        children: [
          _BackgroundDecoration(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                _buildLogo(),
                const SizedBox(height: 8),
                const SuitRow(size: 22, opacity: 0.5),
                const SizedBox(height: 40),
                const GoldDivider(),
                const SizedBox(height: 40),
                Expanded(child: _buildMenu(context)),
                const SizedBox(height: 32),
                _buildFooter(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Crown / card logo
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: TruckiColors.blackCard,
            border: Border.all(
              color: TruckiColors.gold.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: TruckiColors.gold.withOpacity(0.2),
                blurRadius: 24,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: TruckiColors.red.withOpacity(0.1),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '♠',
              style: TextStyle(
                fontSize: 42,
                color: TruckiColors.gold,
                shadows: [
                  Shadow(
                    color: TruckiColors.gold.withOpacity(0.6),
                    blurRadius: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'TRUCKI',
          style: GoogleFonts.playfairDisplay(
            fontSize: 44,
            fontWeight: FontWeight.w800,
            color: TruckiColors.gold,
            letterSpacing: 10,
            shadows: [
              Shadow(
                color: TruckiColors.gold.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
              Shadow(
                color: TruckiColors.red.withOpacity(0.2),
                blurRadius: 40,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'CONTADOR DE PONTOS',
          style: GoogleFonts.lato(
            fontSize: 11,
            color: TruckiColors.textMuted,
            letterSpacing: 5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _MenuButton(
            icon: '♠',
            label: 'INICIAR JOGO',
            subtitle: 'Começar nova partida',
            isPrimary: true,
            onTap: () async {
              await gameState.loadTeamNames();
              gameState.startNewGame();
              if (context.mounted) {
                Navigator.push(
                  context,
                  _slideRoute(InGameScreen(gameState: gameState)),
                );
              }
            },
          ),
          const SizedBox(height: 14),
          _MenuButton(
            icon: '♥',
            label: 'HISTÓRICO',
            subtitle: 'Partidas anteriores',
            isPrimary: false,
            accentColor: TruckiColors.red,
            onTap: () => Navigator.push(
              context,
              _slideRoute(const HistoricScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _MenuButton(
            icon: '♦',
            label: 'CONFIGURAÇÕES',
            subtitle: 'Nomes das equipes',
            isPrimary: false,
            accentColor: TruckiColors.gold.withOpacity(0.7),
            onTap: () => Navigator.push(
              context,
              _slideRoute(ConfigScreen(gameState: gameState)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          '— Boa sorte na mesa —',
          style: GoogleFonts.lato(
            color: TruckiColors.textMuted,
            fontSize: 12,
            letterSpacing: 2,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  PageRoute _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}

// Stateless menu button widget
class _MenuButton extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final bool isPrimary;
  final Color? accentColor;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isPrimary,
    this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? TruckiColors.gold;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: color.withOpacity(0.08),
        highlightColor: color.withOpacity(0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPrimary
                  ? TruckiColors.gold.withOpacity(0.5)
                  : color.withOpacity(0.2),
              width: isPrimary ? 1.5 : 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isPrimary
                  ? [
                      TruckiColors.gold.withOpacity(0.15),
                      TruckiColors.gold.withOpacity(0.04),
                    ]
                  : [
                      color.withOpacity(0.06),
                      Colors.transparent,
                    ],
            ),
          ),
          child: Row(
            children: [
              Text(
                icon,
                style: TextStyle(
                  fontSize: 26,
                  color: color,
                  shadows: [
                    Shadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.playfairDisplay(
                        color: isPrimary ? TruckiColors.gold : TruckiColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.lato(
                        color: TruckiColors.textMuted,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: color.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Stateless background decoration
class _BackgroundDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned.fill(
      child: Stack(
        children: [
          // Top-left glow
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    TruckiColors.red.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom-right glow
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    TruckiColors.gold.withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Corner suits
          Positioned(
            top: 60,
            right: 20,
            child: Opacity(
              opacity: 0.04,
              child: Text(
                '♥',
                style: TextStyle(
                  fontSize: 120,
                  color: TruckiColors.red,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 10,
            child: Opacity(
              opacity: 0.04,
              child: Text(
                '♣',
                style: TextStyle(
                  fontSize: 100,
                  color: TruckiColors.suitBlack,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

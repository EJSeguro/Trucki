import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/suit_widgets.dart';
import '../models/match.dart';
import '../services/storage_service.dart';

class MatchDetailScreen extends StatelessWidget {
  final TruckiMatch match;

  const MatchDetailScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat("dd/MM/yyyy 'às' HH:mm");
    final t1Won = match.winner == match.teamOneName;

    return Scaffold(
      backgroundColor: TruckiColors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Winner banner
                    if (match.winner != null) _buildWinnerBanner(),
                    const SizedBox(height: 20),

                    // Final scoreboard
                    _buildScoreboard(t1Won),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Encerrada em ${df.format(match.endedAt)}',
                        style: GoogleFonts.lato(
                          color: TruckiColors.textMuted,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const GoldDivider(),
                    const SizedBox(height: 24),

                    // Timeline header
                    _sectionLabel('HISTÓRICO DE PONTUAÇÃO'),
                    const SizedBox(height: 16),

                    // Events timeline
                    if (match.events.isEmpty)
                      Center(
                        child: Text(
                          'Nenhum evento registrado.',
                          style: GoogleFonts.lato(
                              color: TruckiColors.textMuted, fontSize: 13),
                        ),
                      )
                    else
                      ...match.events.reversed
                          .map((e) => _EventTile(
                                event: e,
                                team1Name: match.teamOneName,
                                team2Name: match.teamTwoName,
                              ))
                          .toList(),

                    const SizedBox(height: 32),
                    const GoldDivider(),
                    const SizedBox(height: 24),

                    // Delete button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmDelete(context),
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 18),
                        label: const Text('EXCLUIR PARTIDA'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: TruckiColors.red,
                          side: BorderSide(
                              color: TruckiColors.red.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          textStyle: GoogleFonts.lato(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
            'DETALHES',
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
            child: SuitRow(size: 14, opacity: 0.4),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerBanner() {
    return LuxCard(
      borderColor: TruckiColors.gold,
      borderOpacity: 0.45,
      gradientColors: [
        TruckiColors.gold.withOpacity(0.1),
        TruckiColors.blackCard,
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('♔',
              style: TextStyle(color: TruckiColors.gold, fontSize: 26)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VENCEDOR',
                style: GoogleFonts.lato(
                  color: TruckiColors.gold,
                  fontSize: 10,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                match.winner!.toUpperCase(),
                style: GoogleFonts.playfairDisplay(
                  color: TruckiColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreboard(bool t1Won) {
    return LuxCard(
      child: Row(
        children: [
          Expanded(
            child: _FinalScore(
              name: match.teamOneName,
              score: match.teamOneScore,
              isWinner: t1Won,
              suit: '♠',
              suitColor: TruckiColors.suitBlack,
              align: CrossAxisAlignment.start,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: TruckiColors.gold.withOpacity(0.15),
          ),
          Expanded(
            child: _FinalScore(
              name: match.teamTwoName,
              score: match.teamTwoScore,
              isWinner: !t1Won && match.winner != null,
              suit: '♥',
              suitColor: TruckiColors.red,
              align: CrossAxisAlignment.end,
            ),
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
          height: 14,
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
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TruckiColors.blackCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: TruckiColors.gold.withOpacity(0.2)),
        ),
        title: Text('Excluir partida?',
            style: GoogleFonts.playfairDisplay(
                color: TruckiColors.textPrimary,
                fontWeight: FontWeight.w700)),
        content: Text('Esta ação não pode ser desfeita.',
            style: GoogleFonts.lato(
                color: TruckiColors.textMuted, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCELAR',
                style: GoogleFonts.lato(color: TruckiColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              await StorageService.deleteMatch(match.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TruckiColors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('EXCLUIR',
                style:
                    GoogleFonts.lato(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────

class _FinalScore extends StatelessWidget {
  final String name;
  final int score;
  final bool isWinner;
  final String suit;
  final Color suitColor;
  final CrossAxisAlignment align;

  const _FinalScore({
    required this.name,
    required this.score,
    required this.isWinner,
    required this.suit,
    required this.suitColor,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = align == CrossAxisAlignment.start;
    return Padding(
      padding: EdgeInsets.only(
        left: isLeft ? 0 : 16,
        right: isLeft ? 16 : 0,
      ),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Text(suit,
              style: TextStyle(
                  fontSize: 18,
                  color: suitColor,
                  shadows: [
                    Shadow(
                        color: suitColor.withOpacity(0.4), blurRadius: 8)
                  ])),
          const SizedBox(height: 4),
          Text(
            name.toUpperCase(),
            style: GoogleFonts.lato(
              color: isWinner
                  ? TruckiColors.gold
                  : TruckiColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$score',
            style: GoogleFonts.playfairDisplay(
              color: isWinner
                  ? TruckiColors.textPrimary
                  : TruckiColors.textMuted,
              fontSize: 44,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final ScoreEvent event;
  final String team1Name;
  final String team2Name;

  const _EventTile({
    required this.event,
    required this.team1Name,
    required this.team2Name,
  });

  @override
  Widget build(BuildContext context) {
    final isTeam1 = event.team == 1;
    final isAdd = event.delta > 0;
    final teamName = isTeam1 ? team1Name : team2Name;
    final accentColor = isTeam1 ? TruckiColors.gold : TruckiColors.red;
    final suit = isTeam1 ? '♠' : '♥';
    final df = DateFormat('HH:mm:ss  dd/MM');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Timeline line + dot
          Column(
            children: [
              Container(
                width: 1,
                height: 10,
                color: accentColor.withOpacity(0.2),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.4),
                  border: Border.all(color: accentColor, width: 1),
                ),
              ),
              Container(
                width: 1,
                height: 10,
                color: accentColor.withOpacity(0.2),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: accentColor.withOpacity(0.15), width: 1),
                color: accentColor.withOpacity(0.04),
              ),
              child: Row(
                children: [
                  Text(suit,
                      style: TextStyle(
                          fontSize: 14,
                          color: accentColor.withOpacity(0.8))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teamName,
                          style: GoogleFonts.lato(
                            color: TruckiColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          df.format(event.timestamp),
                          style: GoogleFonts.lato(
                            color: TruckiColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Delta badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: isAdd
                          ? Colors.green.withOpacity(0.12)
                          : TruckiColors.red.withOpacity(0.12),
                      border: Border.all(
                        color: isAdd
                            ? Colors.green.withOpacity(0.3)
                            : TruckiColors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${isAdd ? '+' : ''}${event.delta}',
                      style: GoogleFonts.lato(
                        color: isAdd
                            ? const Color(0xFF6FCF97)
                            : TruckiColors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '→ ${event.scoreAfter}',
                    style: GoogleFonts.playfairDisplay(
                      color: accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

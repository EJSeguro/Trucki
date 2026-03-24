import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/suit_widgets.dart';
import '../models/match.dart';
import '../services/storage_service.dart';
import 'match_detail_screen.dart';

class HistoricScreen extends StatefulWidget {
  const HistoricScreen({super.key});

  @override
  State<HistoricScreen> createState() => _HistoricScreenState();
}

class _HistoricScreenState extends State<HistoricScreen> {
  List<TruckiMatch> _matches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final m = await StorageService.getMatches();
    setState(() {
      _matches = m;
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    await StorageService.deleteMatch(id);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Partida excluída.', style: GoogleFonts.lato()),
        backgroundColor: TruckiColors.red.withOpacity(0.85),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  void _confirmDelete(String id) {
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
                color: TruckiColors.textPrimary, fontWeight: FontWeight.w700)),
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
            onPressed: () {
              Navigator.pop(ctx);
              _delete(id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: TruckiColors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: Text('EXCLUIR',
                style: GoogleFonts.lato(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
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
                else if (_matches.isEmpty)
                  const Expanded(child: _EmptyState())
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _load,
                      color: TruckiColors.gold,
                      backgroundColor: TruckiColors.blackCard,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: _matches.length,
                        itemBuilder: (_, i) => _MatchCard(
                          match: _matches[i],
                          onDelete: () => _confirmDelete(_matches[i].id),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    MatchDetailScreen(match: _matches[i]),
                                transitionsBuilder:
                                    (_, anim, __, child) => FadeTransition(
                                  opacity: anim,
                                  child: child,
                                ),
                              ),
                            );
                            _load();
                          },
                        ),
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
      child: Opacity(
        opacity: 0.03,
        child: Center(
          child: Text('♦',
              style: TextStyle(
                  fontSize: 280, color: TruckiColors.gold)),
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
            'HISTÓRICO',
            style: GoogleFonts.playfairDisplay(
              color: TruckiColors.gold,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          Text(
            '${_matches.length} partidas',
            style: GoogleFonts.lato(
              color: TruckiColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

// ── Stateless widgets ─────────────────────────────────────────────────

class _MatchCard extends StatelessWidget {
  final TruckiMatch match;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _MatchCard({
    required this.match,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yy  HH:mm');
    final timeStr = df.format(match.endedAt);
    final t1Won = match.winner == match.teamOneName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: TruckiColors.gold.withOpacity(0.04),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: TruckiColors.gold.withOpacity(0.18), width: 1),
              gradient: LinearGradient(
                colors: [TruckiColors.blackCard, TruckiColors.blackSurface],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    const Text('♠',
                        style: TextStyle(
                            color: TruckiColors.suitBlack, fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(
                      timeStr,
                      style: GoogleFonts.lato(
                          color: TruckiColors.textMuted, fontSize: 11),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(Icons.delete_outline_rounded,
                          color: TruckiColors.red.withOpacity(0.5), size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Score row
                Row(
                  children: [
                    Expanded(
                      child: _TeamResult(
                        name: match.teamOneName,
                        score: match.teamOneScore,
                        isWinner: t1Won,
                        align: TextAlign.left,
                        winColor: TruckiColors.gold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '×',
                        style: GoogleFonts.playfairDisplay(
                          color: TruckiColors.textMuted,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _TeamResult(
                        name: match.teamTwoName,
                        score: match.teamTwoScore,
                        isWinner: !t1Won && match.winner != null,
                        align: TextAlign.right,
                        winColor: TruckiColors.red,
                      ),
                    ),
                  ],
                ),
                if (match.winner != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: TruckiColors.gold.withOpacity(0.35)),
                          color: TruckiColors.gold.withOpacity(0.06),
                        ),
                        child: Text(
                          '♔  ${match.winner!.toUpperCase()} VENCEU',
                          style: GoogleFonts.lato(
                            color: TruckiColors.gold,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded,
                          color: TruckiColors.gold.withOpacity(0.3), size: 16),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamResult extends StatelessWidget {
  final String name;
  final int score;
  final bool isWinner;
  final TextAlign align;
  final Color winColor;

  const _TeamResult({
    required this.name,
    required this.score,
    required this.isWinner,
    required this.align,
    required this.winColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align == TextAlign.left
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          name.toUpperCase(),
          textAlign: align,
          style: GoogleFonts.lato(
            color:
                isWinner ? winColor : TruckiColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: GoogleFonts.playfairDisplay(
            color: isWinner
                ? TruckiColors.textPrimary
                : TruckiColors.textMuted,
            fontSize: 36,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '♠',
            style: TextStyle(
              fontSize: 64,
              color: TruckiColors.textMuted.withOpacity(0.2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma partida registrada',
            style: GoogleFonts.playfairDisplay(
              color: TruckiColors.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inicie um jogo e jogue até o fim!',
            style: GoogleFonts.lato(
              color: TruckiColors.textMuted.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

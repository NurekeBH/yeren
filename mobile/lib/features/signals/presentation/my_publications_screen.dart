import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal.dart';
import '../../../shared/models/trader_post.dart';
import '../../../shared/widgets/error_view.dart';
import '../application/my_publications.dart';
import 'signal_card.dart';

/// «Менің жарияланымдарым» — трейдер өзі жариялаған идеялар (белсенді/жабық) + жазбалар.
class MyPublicationsScreen extends ConsumerWidget {
  const MyPublicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.my_publications),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l.signals_tab_active),
              Tab(text: l.signals_tab_closed),
              Tab(text: l.my_pub_posts),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _IdeasTab(provider: myActiveSignalsProvider),
            _IdeasTab(provider: myClosedSignalsProvider),
            const _PostsTab(),
          ],
        ),
      ),
    );
  }
}

class _IdeasTab extends ConsumerWidget {
  const _IdeasTab({required this.provider});
  final FutureProvider<List<Signal>> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(provider);
    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: () async {
        ref.invalidate(myPublishedSignalsProvider);
        await ref.read(provider.future);
      },
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorRetryView(error: e, onRetry: () => ref.invalidate(myPublishedSignalsProvider)),
        data: (ideas) => ideas.isEmpty
            ? _Empty(label: l.signals_empty)
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                itemCount: ideas.length,
                itemBuilder: (_, i) => SignalCard(signal: ideas[i]),
              ),
      ),
    );
  }
}

class _PostsTab extends ConsumerWidget {
  const _PostsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(myPostsProvider);
    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: () async {
        ref.invalidate(myPostsProvider);
        await ref.read(myPostsProvider.future);
      },
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorRetryView(error: e, onRetry: () => ref.invalidate(myPostsProvider)),
        data: (posts) => posts.isEmpty
            ? _Empty(label: l.posts_empty)
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                itemCount: posts.length,
                itemBuilder: (_, i) => _MyPostCard(post: posts[i]),
              ),
      ),
    );
  }
}

/// Жеке жазба картасы (тек оқу — өз постыңды көру).
class _MyPostCard extends StatelessWidget {
  const _MyPostCard({required this.post});
  final TraderPost post;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.text, style: AppTypography.bodyMedium()),
          if (post.imageUrl != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: post.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                memCacheWidth: (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round(),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.favorite, size: 14, color: AppColors.lossRed),
              const SizedBox(width: 4),
              Text('${post.baseLikes}', style: AppTypography.label(color: AppColors.textSecondary)),
              const SizedBox(width: 14),
              const Icon(Icons.mode_comment_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('${post.seededComments.length}', style: AppTypography.label(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
        const SizedBox(height: 12),
        Center(child: Text(label, style: AppTypography.bodyMedium(color: AppColors.textSecondary))),
      ],
    );
  }
}

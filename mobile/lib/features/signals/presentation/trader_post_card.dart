import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal_provider.dart';
import '../../../shared/models/trader_post.dart';
import '../application/trader_posts_controller.dart';

/// Трейдер посты (Published idea): фото + мәтін + лайк + коммент.
class TraderPostCard extends ConsumerStatefulWidget {
  const TraderPostCard({super.key, required this.post, required this.provider});

  final TraderPost post;
  final SignalProvider provider;

  @override
  ConsumerState<TraderPostCard> createState() => _TraderPostCardState();
}

class _TraderPostCardState extends ConsumerState<TraderPostCard> {
  final _comment = TextEditingController();
  bool _showComments = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final post = widget.post;
    final remote = AppConfig.useRemoteApi;
    final ud = ref.watch(traderPostsUserProvider)[post.id] ?? const PostUserData();
    final liked = ud.liked;
    // Remote: лайк/коммент сервермен бірге келеді. Mock: база + локал overlay.
    final likeCount = remote ? post.baseLikes : post.baseLikes + (liked ? 1 : 0);
    final comments = remote
        ? post.seededComments
        : <PostComment>[
            ...post.seededComments,
            ...ud.comments.map((t) => PostComment(author: l.posts_you, text: t, isMine: true)),
          ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  Text(widget.provider.avatar, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(widget.provider.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w700)),
                            ),
                            if (widget.provider.verified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, size: 14, color: AppColors.dxyBlue),
                            ],
                          ],
                        ),
                        if (post.agoLabel != null)
                          Text(post.agoLabel!, style: AppTypography.label(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Text
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Text(post.text, style: AppTypography.bodyMedium().copyWith(height: 1.45)),
            ),

            // Photo
            if (post.imageUrl != null)
              CachedNetworkImage(
                imageUrl: post.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (_, _) => Container(
                  height: 200,
                  color: AppColors.dxyBlue.withValues(alpha: 0.06),
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Row(
                children: [
                  _ActionButton(
                    icon: liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? AppColors.lossRed : AppColors.textSecondary,
                    label: '$likeCount',
                    onTap: () => _toggleLike(post.id),
                  ),
                  _ActionButton(
                    icon: Icons.mode_comment_outlined,
                    color: AppColors.textSecondary,
                    label: '${comments.length}',
                    onTap: () => setState(() => _showComments = !_showComments),
                  ),
                ],
              ),
            ),

            // Comments
            if (_showComments) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comments.isEmpty ? l.posts_comments_count(0) : l.posts_comments_title,
                      style: AppTypography.label(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    for (final cm in comments) _CommentRow(comment: cm),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _comment,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(post.id),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: l.posts_comment_hint,
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: l.posts_send,
                          icon: const Icon(Icons.send_rounded, color: AppColors.gold),
                          onPressed: () => _send(post.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _toggleLike(String postId) {
    // Heart fill — локал; Remote режимде сервер count-ы invalidate-тен кейін жаңарады.
    ref.read(traderPostsUserProvider.notifier).toggleLike(postId);
    if (AppConfig.useRemoteApi) {
      ref.read(apiServiceProvider).likePost(postId).then((_) {
        ref.invalidate(traderPostsProvider(widget.provider.id));
      }).catchError((_) {});
    }
  }

  void _send(String postId) {
    final text = _comment.text.trim();
    if (text.isEmpty) return;
    if (AppConfig.useRemoteApi) {
      ref.read(apiServiceProvider).commentPost(postId, text).then((_) {
        ref.invalidate(traderPostsProvider(widget.provider.id));
      }).catchError((_) {});
    } else {
      ref.read(traderPostsUserProvider.notifier).addComment(postId, text);
    }
    _comment.clear();
    FocusScope.of(context).unfocus();
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.color, required this.label, required this.onTap});

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: color, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
      icon: Icon(icon, size: 20, color: color),
      label: Text(label, style: AppTypography.bodyMedium(color: color)),
    );
  }
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({required this.comment});
  final PostComment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: AppTypography.bodyMedium().copyWith(height: 1.4),
          children: [
            TextSpan(
              text: '${comment.author}  ',
              style: AppTypography.bodyMedium(color: comment.isMine ? AppColors.gold : AppColors.dxyBlue)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: comment.text),
          ],
        ),
      ),
    );
  }
}

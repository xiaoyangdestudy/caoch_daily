import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/app_routes.dart';
import '../../../shared/design/app_colors.dart';
import '../../../shared/design/app_shadows.dart';
import '../application/moments_provider.dart';
import '../domain/moment_model.dart';

class MomentsPage extends ConsumerWidget {
  const MomentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final momentsAsync = ref.watch(momentsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(momentsProvider.notifier).refresh();
          },
          color: AppColors.candyBlue,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '动态',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () async {
                          final result = await context.push(AppRoutes.createMoment);
                          if (result == true) {
                            ref.read(momentsProvider.notifier).refresh();
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.candyBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text(
                          '发布',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              momentsAsync.when(
                data: (moments) {
                  if (moments.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: AppShadows.cardSoft,
                              ),
                              child: Icon(
                                Icons.photo_library_outlined,
                                size: 48,
                                color: AppColors.candyBlue.withAlpha(128),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              '还没有动态',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '分享你的生活瞬间，记录美好时刻',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // 瀑布流布局
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childCount: moments.length,
                      itemBuilder: (context, index) {
                        return _MomentCard(moment: moments[index]);
                      },
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            '加载失败: ${error.toString()}',
                            style: TextStyle(color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(momentsProvider.notifier).refresh();
                          },
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MomentCard extends ConsumerWidget {
  const _MomentCard({required this.moment});

  final Moment moment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MM-dd HH:mm');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片（如果有）
          if (moment.imageUrls.isNotEmpty)
            _ImageSection(imageUrls: moment.imageUrls),

          // 内容部分
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头像和用户信息
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.candyPurple.withAlpha(26),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        moment.userAvatar ?? '🧠',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            moment.username,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            dateFormat.format(moment.createdAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 更多按钮
                    PopupMenuButton(
                      icon: Icon(
                        Icons.more_horiz,
                        color: Colors.grey.shade400,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('删除', style: TextStyle(color: Colors.red, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'delete') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('确认删除'),
                              content: const Text('确定要删除这条动态吗？'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('取消'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('删除'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await ref.read(momentsProvider.notifier).deleteMoment(moment.id);
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 内容文本
                Text(
                  moment.content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                ),

                // 标签
                if (moment.tags != null && moment.tags!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: moment.tags!.take(3).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.candyBlue.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.candyBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                ],

                // 位置
                if (moment.location != null && moment.location!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          moment.location!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 10),
                Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
                const SizedBox(height: 10),

                // 底部操作栏
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 点赞
                    GestureDetector(
                      onTap: () {
                        ref.read(momentsProvider.notifier).toggleLike(moment.id);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Icon(
                            moment.isLiked ? Icons.favorite : Icons.favorite_border_rounded,
                            size: 18,
                            color: moment.isLiked ? AppColors.candyPink : Colors.grey.shade500,
                          ),
                          if (moment.likes > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '${moment.likes}',
                              style: TextStyle(
                                fontSize: 12,
                                color: moment.isLiked ? AppColors.candyPink : Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // 评论
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('评论功能开发中...')),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 17,
                            color: Colors.grey.shade500,
                          ),
                          if (moment.commentsCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '${moment.commentsCount}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // 分享
                    Icon(
                      Icons.share_outlined,
                      size: 17,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 图片区域组件
class _ImageSection extends StatelessWidget {
  const _ImageSection({required this.imageUrls});

  final List<String> imageUrls;

  /// 检查是否是本地文件路径
  bool _isLocalPath(String path) {
    return !path.startsWith('http://') && !path.startsWith('https://');
  }

  /// 构建单个图片组件
  Widget _buildImage(String imagePath, {double? height}) {
    if (_isLocalPath(imagePath)) {
      // 本地文件
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height ?? 180,
          color: Colors.grey.shade100,
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey, size: 32),
          ),
        ),
      );
    } else {
      // 网络图片
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        placeholder: (context, url) => Container(
          height: height ?? 180,
          color: Colors.grey.shade100,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: height ?? 180,
          color: Colors.grey.shade100,
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey, size: 32),
          ),
        ),
      );
    }
  }

  /// 构建网格图片组件
  Widget _buildGridImage(String imagePath) {
    if (_isLocalPath(imagePath)) {
      // 本地文件
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.shade100,
          child: const Center(
            child: Icon(Icons.broken_image, size: 20, color: Colors.grey),
          ),
        ),
      );
    } else {
      // 网络图片
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade100,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade100,
          child: const Center(
            child: Icon(Icons.broken_image, size: 20, color: Colors.grey),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    // 单张图片
    if (imageUrls.length == 1) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: _buildImage(imageUrls.first, height: 180),
      );
    }

    // 多张图片 - 2x2或3x3网格
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: imageUrls.length == 2 || imageUrls.length == 4 ? 2 : 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1,
        ),
        itemCount: imageUrls.length > 9 ? 9 : imageUrls.length,
        itemBuilder: (context, index) {
          return _buildGridImage(imageUrls[index]);
        },
      ),
    );
  }
}

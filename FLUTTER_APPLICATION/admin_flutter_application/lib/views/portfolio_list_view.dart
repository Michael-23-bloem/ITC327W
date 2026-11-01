
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/portfolio_viewmodel.dart';
import '../models/portfolio.dart';
import 'portfolio_edit_view.dart';

class PortfolioListView extends StatefulWidget {
  const PortfolioListView({super.key});

  @override
  State<PortfolioListView> createState() => _PortfolioListViewState();
}

class _PortfolioListViewState extends State<PortfolioListView> {
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PortfolioViewModel>().load();
      }
    });
  }

  // Groups portfolio entries according to their category.
  Map<String, List<Portfolio>> _groupPortfolioByCategory(
    List<Portfolio> events,
  ) {
    final Map<String, List<Portfolio>> grouped = {};

    for (final event in events) {
      final category = event.category?.trim();

      final key = category == null || category.isEmpty
          ? 'Uncategorised'
          : category;

      grouped.putIfAbsent(key, () => []).add(event);
    }

    // Sort entries within each category: newest first.
    for (final entries in grouped.values) {
      entries.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );
    }

    // Sort categories alphabetically.
    // Keep Uncategorised at the bottom.
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 'Uncategorised') return 1;
        if (b == 'Uncategorised') return -1;

        return a.toLowerCase().compareTo(b.toLowerCase());
      });

    return {
      for (final key in sortedKeys) key: grouped[key]!,
    };
  }

  // Opens the category filter bottom sheet.
  void _showCategoryFilter(List<String> categories) {
    final filterOptions = ['All', ...categories];

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  'Filter by category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filterOptions.length,
                  itemBuilder: (context, index) {
                    final category = filterOptions[index];

                    final isSelected =
                        _selectedCategory == category;

                    return ListTile(
                      dense: true,
                      title: Text(
                        category == 'All'
                            ? 'All Categories'
                            : category,
                      ),
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });

                        Navigator.pop(sheetContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PortfolioViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Dashboard',
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Portfolio'),

        // Category filter icon.
        actions: [
          IconButton(
            tooltip: 'Filter by category',
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              final grouped =
                  _groupPortfolioByCategory(vm.events);

              _showCategoryFilter(grouped.keys.toList());
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/portfolio/upload'),
        child: const Icon(Icons.add),
      ),

      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(vm.error!),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: vm.load,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : vm.events.isEmpty
                  ? const Center(
                      child: Text('No portfolio events yet'),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final columns =
                            constraints.maxWidth < 600 ? 3 : 4;

                        final grouped =
                            _groupPortfolioByCategory(vm.events);

                        final categories =
                            grouped.keys.toList();

                        // Show all categories or only the selected one.
                        final visibleCategories =
                            _selectedCategory == 'All'
                                ? categories
                                : grouped.containsKey(_selectedCategory)
                                    ? [_selectedCategory]
                                    : categories;

                        return ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: visibleCategories.length,
                          itemBuilder: (context, index) {
                            final category =
                                visibleCategories[index];

                            final events = grouped[category]!;

                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // Category heading.
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 12,
                                    bottom: 10,
                                    left: 2,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          category.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${events.length} ${events.length == 1 ? 'entry' : 'entries'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Category images.
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    mainAxisSpacing: 4,
                                    crossAxisSpacing: 4,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: events.length,
                                  itemBuilder: (context, imageIndex) {
                                    final event = events[imageIndex];

                                    return GestureDetector(
                                      onTap: () =>
                                          _showPortfolioSheet(context, event),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(4),
                                        child: event.imageUrl.isEmpty
                                            ? Container(
                                                color: Colors.grey.shade200,
                                                child: const Icon(
                                                  Icons.image_outlined,
                                                ),
                                              )
                                            : Image.network(
                                                event.imageUrl,
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Container(
                                                    color:
                                                        Colors.grey.shade200,
                                                    child: const Icon(
                                                      Icons
                                                          .broken_image_outlined,
                                                    ),
                                                  );
                                                },
                                              ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 12),
                              ],
                            );
                          },
                        );
                      },
                    ),
    );
  }

  void _showPortfolioSheet(BuildContext context, Portfolio p) {
    final vm = context.read<PortfolioViewModel>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FutureBuilder<Map<String, dynamic>>(
        future: vm.loadDetail(p.id),
        builder: (ctx, snapshot) {
          final images = [
            p.imageUrl,
            ...(snapshot.data?['images'] as List<String>? ?? []),
          ];

          final items =
              snapshot.data?['items'] as List<String>? ?? [];

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 200,
                    child: snapshot.connectionState ==
                            ConnectionState.waiting
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : PageView(
                            children: images
                                .map(
                                  (url) => ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${images.length} photo${images.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Colors.black45,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (p.category != null)
                    Text(
                      p.category!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                  if (p.price != null)
                    Text(
                      'R${p.price!.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),

                  if (p.description != null) ...[
                    const SizedBox(height: 8),
                    Text(p.description!),
                  ],

                  if (items.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Items used',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: items
                          .map(
                            (name) => Chip(
                              label: Text(name),
                            ),
                          )
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);

                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                PortfolioEditView(portfolio: p),
                          ),
                        );

                        if (mounted) {
                          await vm.load();
                        }
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: ctx,
                          builder: (dialogCtx) => AlertDialog(
                            title: const Text('Delete this item?'),
                            content: const Text(
                              'This will permanently remove it and its photos.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogCtx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogCtx, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await vm.deletePortfolio(p.id);

                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                            }
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text('Delete failed: $e'),
                                ),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

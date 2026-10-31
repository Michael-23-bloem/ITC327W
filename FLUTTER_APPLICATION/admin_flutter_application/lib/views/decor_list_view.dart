
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/decor_product.dart';
import '../viewmodels/decor_product_viewmodel.dart';
import 'decor_edit_view.dart';

class DecorListView extends StatefulWidget {
  const DecorListView({super.key});

  @override
  State<DecorListView> createState() => _DecorListViewState();
}

class _DecorListViewState extends State<DecorListView> {
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DecorProductViewModel>().loadCatalogue();
      }
    });
  }

  // Groups products according to their category.
  Map<String, List<DecorProduct>> _groupCatalogueByCategory(
    List<DecorProduct> products,
  ) {
    final Map<String, List<DecorProduct>> grouped = {};

    for (final product in products) {
      final category = product.category?.trim();

      final key = category == null || category.isEmpty
          ? 'Uncategorised'
          : category;

      grouped.putIfAbsent(key, () => []).add(product);
    }

    // Sort category names alphabetically.
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

  /*void _showCategoryFilter(List<String> categories) {
    final filterOptions = ['All', ...categories];

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Text(
                    'Filter by category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ...filterOptions.map((category) {
                  final isSelected =
                      _selectedCategory == category;

                  return ListTile(
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
                }),
              ],
            ),
          ),
        );
      },
    );
  }*/

  Future<void> _showPopup({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(icon, color: iconColor, size: 48),
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DecorProductViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Décor Catalogue'),

        // Category filter icon.
        actions: [
          IconButton(
            tooltip: 'Filter by category',
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              final groupedProducts =
                  _groupCatalogueByCategory(vm.catalogue);

              final categories =
                  groupedProducts.keys.toList();

              _showCategoryFilter(categories);
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/decor/upload'),
        child: const Icon(Icons.add),
      ),

      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.catalogue.isEmpty
              ? const Center(child: Text('No décor items yet'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    // Three columns on phones.
                    // Four columns on wider screens.
                    final columns =
                        constraints.maxWidth < 600 ? 3 : 4;

                    final groupedProducts =
                        _groupCatalogueByCategory(vm.catalogue);

                    final categories =
                        groupedProducts.keys.toList();

                    // Show all categories or only the selected one.
                    final visibleCategories =
                        _selectedCategory == 'All'
                            ? categories
                            : groupedProducts
                                    .containsKey(_selectedCategory)
                                ? [_selectedCategory]
                                : categories;

                    return RefreshIndicator(
                      onRefresh: vm.loadCatalogue,
                      child: ListView.builder(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        itemCount: visibleCategories.length,
                        itemBuilder: (context, index) {
                          final category =
                              visibleCategories[index];

                          final products =
                              groupedProducts[category]!;

                          return Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              // Category heading.
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 12,
                                  bottom: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        category,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${products.length} items',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Products belonging to this category.
                              GridView.builder(
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 0.62,
                                ),
                                itemCount: products.length,
                                itemBuilder:
                                    (context, productIndex) {
                                  final product =
                                      products[productIndex];

                                  return GestureDetector(
                                    onTap: () =>
                                        _showDetails(product),
                                    child: Card(
                                      clipBehavior:
                                          Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: product.imageUrl ==
                                                          null ||
                                                      product.imageUrl!
                                                          .isEmpty
                                                  ? const Icon(
                                                      Icons
                                                          .image_outlined,
                                                      size: 40,
                                                    )
                                                  : Image.network(
                                                      product.imageUrl!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (_, __, ___) =>
                                                              const Icon(
                                                        Icons
                                                            .broken_image_outlined,
                                                        size: 36,
                                                      ),
                                                    ),
                                            ),
                                          ),

                                          Padding(
                                            padding:
                                                const EdgeInsets.all(7),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'R${product.price.toStringAsFixed(2)}',
                                                  style:
                                                      const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                Text(
                                                  'Stock: ${product.stockQuantity}',
                                                  style:
                                                      const TextStyle(
                                                    color:
                                                        Colors.black54,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  void _showDetails(DecorProduct product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final vm = context.read<DecorProductViewModel>();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.imageUrl != null &&
                      product.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        product.imageUrl!,
                        width: double.infinity,
                        height: 210,
                        fit: BoxFit.cover,
                      ),
                    ),

                  const SizedBox(height: 16),

                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Category: ${product.category ?? 'Uncategorised'}',
                  ),
                  Text(
                    'Price: R${product.price.toStringAsFixed(2)}',
                  ),
                  Text('Total stock: ${product.stockQuantity}'),

                  if (product.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Text(product.description!),
                  ],

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(sheetContext);

                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                DecorEditView(product: product),
                          ),
                        );

                        if (mounted) {
                          await vm.loadCatalogue();
                        }
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Décor Item'),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(sheetContext);

                        final confirm =
                            await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) =>
                              AlertDialog(
                            title: const Text(
                              'Delete décor item?',
                            ),
                            content: Text(
                              'Delete "${product.name}" from the catalogue? '
                              'This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(
                                  dialogContext,
                                  false,
                                ),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(
                                  dialogContext,
                                  true,
                                ),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm != true || !mounted) return;

                        try {
                          await vm.deleteDecor(product.id);

                          if (!mounted) return;

                          await _showPopup(
                            title: 'Item deleted',
                            message:
                                '"${product.name}" has been removed '
                                'from the catalogue.',
                            icon: Icons.check_circle_outline,
                            iconColor: Colors.green,
                          );
                        } catch (e) {
                          if (!mounted) return;

                          await _showPopup(
                            title: 'Delete failed',
                            message: e
                                .toString()
                                .replaceFirst('Exception: ', ''),
                            icon: Icons.error_outline,
                            iconColor: Colors.red,
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Delete Décor Item',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

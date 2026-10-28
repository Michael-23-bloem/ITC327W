import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/decor_product.dart';
import '../theme/akea_theme.dart';
import '../viewmodels/decor_product_viewmodel.dart';
import '../widgets/akea_ui.dart';
import 'decor_edit_view.dart';

class DecorListView extends StatefulWidget {
  const DecorListView({super.key});

  @override
  State<DecorListView> createState() => _DecorListViewState();
}

class _DecorListViewState extends State<DecorListView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DecorProductViewModel>().loadCatalogue();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DecorProductViewModel>();

    return AkeaPage(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
            child: AkeaPageHeader(
              title: 'Décor catalogue',
              subtitle: 'Items available to quote',
              actions: [
                AkeaButton(
                  label: 'Upload',
                  onPressed: () => context.push('/decor/upload'),
                ),
              ],
            ),
          ),
          Expanded(
            child: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.catalogue.isEmpty
          ? const Center(child: Text('No décor items yet'))
          : RefreshIndicator(
              onRefresh: vm.loadCatalogue,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth >= 1100
                      ? 4
                      : constraints.maxWidth >= 720
                          ? 3
                          : 2;
                  return GridView.builder(
                padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.78,
                ),
                itemCount: vm.catalogue.length,
                itemBuilder: (context, index) {
                  final product = vm.catalogue[index];

                  return GestureDetector(
                    onTap: () => _showDetails(context, product),
                    child: Material(
                      color: AkeaColors.card,
                      borderRadius: BorderRadius.circular(18),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child:
                                  product.imageUrl == null ||
                                      product.imageUrl!.isEmpty
                                  ? const Icon(Icons.image_outlined, size: 48)
                                  : Image.network(
                                      product.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.broken_image_outlined,
                                        size: 40,
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('R${product.price.toStringAsFixed(2)}'),
                                Text(
                                  'Stock: ${product.stockQuantity}',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
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
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, DecorProduct product) {
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
                  if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
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
                  Text('Category: ${product.category ?? 'Uncategorised'}'),
                  Text('Price: R${product.price.toStringAsFixed(2)}'),
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
                            builder: (_) => DecorEditView(product: product),
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
  Navigator.pop(sheetContext); // close the details sheet first, same as Edit does

  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete décor item?'),
      content: Text(
        'Delete "${product.name}" from the catalogue? '
        'This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirm != true || !context.mounted) return;

  try {
    await context.read<DecorProductViewModel>().deleteDecor(product.id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Décor item deleted successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Could not delete décor item: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
  }
},
                      /*onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: sheetContext,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Delete décor item?'),
                            content: Text(
                              'Delete "${product.name}" from the catalogue? '
                              'This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm != true || !context.mounted) return;

                        try {
                          await context
                              .read<DecorProductViewModel>()
                              .deleteDecor(product.id);

                          if (!context.mounted) return;

                          // Close the details bottom sheet.
                          Navigator.pop(sheetContext);

                          // Show a success message on the catalogue page.
                          ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                  ' Décor item deleted successfully!',
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                              ),
                            );
                        } catch (e) {
                          if (!context.mounted) return;

                          // Show an error message if deletion fails.
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(
                                  ' Could not delete décor item: $e',
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                        }
                      },*/
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
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

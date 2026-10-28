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
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DecorProductViewModel>().loadCatalogue();
      }
    });
  }

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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/decor/upload'),
        child: const Icon(Icons.add),
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.catalogue.isEmpty
          ? const Center(child: Text('No décor items yet'))
          : RefreshIndicator(
              onRefresh: vm.loadCatalogue,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: vm.catalogue.length,
                itemBuilder: (context, index) {
                  final product = vm.catalogue[index];

                  return GestureDetector(
                    // FIX A: no longer passes the tile's context
                    onTap: () => _showDetails(product),
                    child: Card(
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
                                      errorBuilder: (_, __, ___) => const Icon(
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
              ),
            ),
    );
  }

  // FIX B: no BuildContext parameter, so `context` is the screen's own
  // context and `mounted` stays true while the spinner is showing.
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
                      // FIX C: uses `mounted` and popups instead of the
                      // stale tile context and snackbars.
                      onPressed: () async {
                        Navigator.pop(sheetContext);

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

                        if (confirm != true || !mounted) return;

                        try {
                          await vm.deleteDecor(product.id);

                          if (!mounted) return;

                          await _showPopup(
                            title: 'Item deleted',
                            message:
                                '"${product.name}" has been removed from the catalogue.',
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
/*import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DecorProductViewModel>().loadCatalogue();
      }
    });
  }

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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/decor/upload'),///decor....needs to be check??/
        child: const Icon(Icons.add),
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.catalogue.isEmpty
          ? const Center(child: Text('No décor items yet'))
          : RefreshIndicator(
              onRefresh: vm.loadCatalogue,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: vm.catalogue.length,
                itemBuilder: (context, index) {
                  final product = vm.catalogue[index];

                  return GestureDetector(
                    onTap: () => _showDetails(context, product),
                    child: Card(
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
                                      errorBuilder: (_, __, ___) => const Icon(
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
              ),
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
}*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "../../../common/category_header.dart";
import '../../../common/custom_search_bar.dart';
import '../providers/emoji_provider.dart';
import '../utils/emoji_utils.dart';
import './emoji_grid_view.dart';

class BuildEmojis extends StatelessWidget {
  const BuildEmojis({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('BuildEmojis build is called');
    final emojiProvider = context.read<EmojiProvider>();

    return Column(
      children: [
        Selector<EmojiProvider, bool>(
            selector: (_, provider) => provider.showSearchBar,
            builder: (_, showSearchbar, child) {
              debugPrint('Emojis searchbar builder called');
              if (showSearchbar) {
                return CustomSearchBox(
                  hintText: 'Search emojis',
                  controller: emojiProvider.searchController,
                  onChanged: emojiProvider.searchEmoji,
                );
              }
              return const SizedBox.shrink();
            }),
        Expanded(
          child: CustomScrollView(
            controller: emojiProvider.scrollController,
            slivers: _buildSliverList(context),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSliverList(BuildContext context) {
    final List<Widget> slivers = [];

    final (query, searchResultList) = context.select(
      (EmojiProvider p) => (p.searchController.text, p.searchResultList),
    );

    // render search result
    if (query.isNotEmpty) {
      if (query.isNotEmpty) {
        final noResults = searchResultList.isEmpty;
        final label = noResults ? 'No results found' : 'Results';

        final searchList = EmojiUtils.filterCustomEmojis(searchResultList);

        slivers.add(CategoryHeader(label: label));
        slivers.add(EmojiGridView(emojis: searchList));
      }
      return slivers;
    }

    // render all emojis
    final categories = EmojiProvider.categories;
    for (var category in categories) {
      slivers.add(CategoryHeader(label: category.$1));

      final uniqueEmojis = EmojiUtils.filterCustomEmojis(category.$2);
      slivers.add(EmojiGridView(emojis: uniqueEmojis));
    }

    return slivers;
  }
}

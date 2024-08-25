import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/category_header.dart';
import '../../../common/custom_search_bar.dart';
import '../providers/emoticon_provider.dart';
import './emoticon_grid_view.dart';

class BuildEmoticons extends StatelessWidget {
  const BuildEmoticons({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('BuildEmoticons build is called');
    final emoticonProvider = context.read<EmoticonProvider>();

    return Column(
      children: [
        Selector<EmoticonProvider, bool>(
            selector: (_, provider) => provider.showSearchBar,
            builder: (_, showSearchbar, child) {
              debugPrint('Emoticon searchbar builder called');
              if (showSearchbar) {
                return CustomSearchBox(
                  hintText: 'Search emoticons',
                  controller: emoticonProvider.searchController,
                  onChanged: (p0) => emoticonProvider.searchEmoticon(p0),
                );
              }
              return const SizedBox.shrink();
            }),
        Expanded(
          child: CustomScrollView(
            controller: emoticonProvider.scrollController,
            slivers: _buildSliverList(context),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSliverList(BuildContext context) {
    final List<Widget> slivers = [];

    final (query, searchResultList) = context.select(
      (EmoticonProvider p) => (p.searchController.text, p.searchResultList),
    );

    // render search result
    if (query.isNotEmpty) {
      if (query.isNotEmpty) {
        final noResults = searchResultList.isEmpty;
        final label = noResults ? 'No results found' : 'Results';

        slivers.add(CategoryHeader(label: label));
        slivers.add(EmoticonGridView(emoticons: searchResultList));
      }
      return slivers;
    }

    // render all emoticon
    final categories = EmoticonProvider.categories;
    for (var category in categories) {
      slivers.add(CategoryHeader(label: category.$1));
      slivers.add(EmoticonGridView(emoticons: category.$2));
    }

    return slivers;
  }
}

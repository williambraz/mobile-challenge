import 'package:flutter/material.dart';
import 'package:mobile_challenge/data/providers/connection.dart';
import 'package:mobile_challenge/data/providers/search.dart';
import 'package:mobile_challenge/presentation/components/user_card.dart';
import 'package:mobile_challenge/presentation/view_models/search_view_model.dart';
import 'package:provider/provider.dart';

class SearchView extends StatefulWidget {
  static String routeName = '/search';
  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final searchViewModel = SearchViewModel();
  final _form = GlobalKey<FormState>();
  final _searchFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    reloadLastSearch();
    listenKeyboardChanges();
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    super.dispose();
  }

  reloadLastSearch() {
    final String initialSearchValue =
        Provider.of<SearchProvider>(context, listen: false).search;
    _searchFieldController.text = initialSearchValue;
    if (initialSearchValue.length > 0) {
      onSearch(initialSearchValue);
    }
  }

  listenKeyboardChanges() =>
      _searchFieldController.addListener(onSearchFieldChange);

  onSearchFieldChange() => searchViewModel.clearSearchError();

  tryValidate() {
    Future.delayed(const Duration(milliseconds: 100),
        () => _form.currentState?.validate() ?? null);
  }

  onSearch(String searchData) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enviando...')),
    );
    await searchViewModel.search(searchData);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() => tryValidate());
  }

  Widget _showForm() => Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: 'Nome',
              ),
              controller: _searchFieldController,
              onChanged: (value) =>
                  Provider.of<SearchProvider>(context, listen: false).search =
                      value,
              validator: (value) {
                if (!searchViewModel.haveFoundUsers()) {
                  return 'Não foram encontrados usuários com esta busca';
                }
                if (value!.isEmpty) {
                  return 'Digite o nome do usuário';
                }
                return null;
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
            ),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Buscar'),
                    Icon(Icons.search),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                ),
                onPressed: () => {
                  if (_form.currentState!.validate())
                    {
                      onSearch(_searchFieldController.text),
                    },
                },
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isConnected = Provider.of<ConnectionProvider>(context).isConnected;
    final users = searchViewModel.getUsers();
    return Container(
      margin: EdgeInsets.all(10),
      child: isConnected
          ? Container(
              child: Column(
                children: [
                  _showForm(),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          return UserCard(users[index]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Não é possível realizar buscas, verifique a sua conexão com a Internet.',
              ),
            ),
    );
  }
}

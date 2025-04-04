import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/core/home/home.dart';
import 'package:holz_logistik/users_screen/user_list/view/view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select((HomeCubit cubit) => cubit.state.tab);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Holz Logistik'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(UserListPage.route()),
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedTab.index,
        children: const [
          Center(child: Text('Standorte')),
          Center(child: Text('Karte')),
          Center(child: Text('Abfuhren')),
          Center(child: Text('Analyse')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab.index,
        onTap: (index) =>
            {context.read<HomeCubit>().setTab(HomeTab.values[index])},
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Standorte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Karte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Abfuhren',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analyse',
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/github_sync_service.dart';
import '../../models/recipe.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  bool _isSyncing = false;
  int _syncedCount = 0;
  String _message = '';
  List<Recipe> _newRecipes = [];

  Future<void> _syncRecipes() async {
    setState(() {
      _isSyncing = true;
      _syncedCount = 0;
      _message = '正在获取数据...';
      _newRecipes = [];
    });

    try {
      final syncService = GitHubSyncService();
      final remoteRecipes = await syncService.syncRecipes();

      if (remoteRecipes.isEmpty) {
        setState(() {
          _isSyncing = false;
          _message = '没有找到新菜谱';
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final existingJson = prefs.getString('family_menu_recipes');
      final existingIds = <String>{};
      if (existingJson != null) {
        final List<dynamic> existingList = json.decode(existingJson);
        for (final item in existingList) {
          existingIds.add(item['id'] as String);
        }
      }

      final newRecipes = remoteRecipes
          .where((recipe) => !existingIds.contains(recipe.id))
          .toList();

      if (newRecipes.isEmpty) {
        setState(() {
          _isSyncing = false;
          _message = '已更新到最新版本';
        });
        return;
      }

      final allRecipes = existingJson != null
          ? [...json.decode(existingJson), ...newRecipes.map((r) => r.toJson())]
          : newRecipes.map((r) => r.toJson()).toList();

      await prefs.setString('family_menu_recipes', json.encode(allRecipes));
      await prefs.setInt('family_menu_version', DateTime.now().millisecondsSinceEpoch);

      setState(() {
        _isSyncing = false;
        _syncedCount = newRecipes.length;
        _message = '更新完成！新增 $_syncedCount 道菜谱';
        _newRecipes = newRecipes;
      });
    } catch (e) {
      setState(() {
        _isSyncing = false;
        _message = '更新失败: $e';
      });
    }
  }

  Future<void> _restoreDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('family_menu_recipes');
    await prefs.remove('family_menu_version');

    setState(() {
      _message = '已恢复默认菜谱';
      _newRecipes = [];
      _syncedCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('更新菜谱'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.refresh,
                      size: 64,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '更新菜谱',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '获取最新菜谱数据，丰富您的菜单选择',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_message.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _message.contains('失败') ? Colors.red : Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_newRecipes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          '新增菜谱:',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            itemCount: _newRecipes.length,
                            itemBuilder: (context, index) {
                              final recipe = _newRecipes[index];
                              return ListTile(
                                leading: Text(recipe.categoryIcon),
                                title: Text(recipe.name),
                                subtitle: Text(recipe.categoryName),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSyncing ? null : _syncRecipes,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _isSyncing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(width: 12),
                        Text('更新中...'),
                      ],
                    )
                  : const Text('点击更新菜谱'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _restoreDefault,
              child: const Text('恢复默认菜谱'),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 更新说明',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('• 点击"点击更新菜谱"获取最新菜谱数据'),
                    const Text('• 只会添加本地没有的新菜谱'),
                    const Text('• 更新后需要重新进入应用查看'),
                    const Text('• 如遇问题可点击"恢复默认菜谱"'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
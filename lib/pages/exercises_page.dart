import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timly/bloc/persistence/persistence_bloc.dart';
import 'package:timly/bloc/persistence/persistence_event.dart';
import 'package:timly/bloc/persistence/persistence_state.dart';
import 'package:timly/bloc/sound/sound_bloc.dart';
import 'package:timly/bloc/timer/timer_bloc.dart';
import 'package:timly/model/exercise.dart';
import 'package:timly/pages/exercises_edit_page.dart';
import 'package:timly/pages/timer_page.dart';

class ExercisesPage extends StatefulWidget {
  @override
  _ExercisesPageState createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  @override
  void initState() {
    context.bloc<PersistenceBloc>().add(PersistenceEvent.loadAll());
    super.initState();
  }

  @override
  Widget build(BuildContext pageContext) {
    return BlocBuilder<PersistenceBloc, PersistenceState>(
      builder: (context, state) {
        return state.when(
            error: () =>
                Scaffold(body: Center(child: Text('Ein Fehler ist passiert.'))),
            init: () =>
                Scaffold(body: Center(child: CircularProgressIndicator())),
            loaded: (exercises) =>
                _ExercisesList(exercises, context.bloc<PersistenceBloc>()));
      },
    );
  }
}

class _ExercisesList extends StatefulWidget {
  final List<Exercise> _exercises;
  final PersistenceBloc _persistenceBloc;

  _ExercisesList(this._exercises, this._persistenceBloc);

  @override
  __ExercisesListState createState() => __ExercisesListState();
}

class __ExercisesListState extends State<_ExercisesList> {
  PersistenceBloc get persistenceBloc => widget._persistenceBloc;

  bool get _selecting => _indexOfSelected.isNotEmpty;

  List<int> _indexOfSelected = [];

  bool _isSelected(int index) => _indexOfSelected.contains(index);

  Widget _floatingButton() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        _resetSelection();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                ExercisesEditPage(persistenceBloc: persistenceBloc)));
      },
    );
  }

  void _resetSelection() {
    _indexOfSelected = [];
    setState(() {});
  }

  List<Widget> _actions() {
    var deleteButton = IconButton(
      icon: Icon(Icons.delete),
      onPressed: () {
        persistenceBloc.add(PersistenceEvent.deleteAll(List.generate(
            _indexOfSelected.length,
            (index) => widget._exercises.elementAt(_indexOfSelected[index]))));
        _resetSelection();
      },
    );

    if (_indexOfSelected.length == 1) {
      print(_indexOfSelected);
      return [
        deleteButton,
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => ExercisesEditPage(
                        persistenceBloc: persistenceBloc,
                        exercise: widget._exercises
                            .elementAt(_indexOfSelected.elementAt(0)))))
                .then((value) => _resetSelection());
          },
        )
      ];
    } else if (_indexOfSelected.length > 1) {
      return [deleteButton];
    }
  }

  @override
  Widget build(BuildContext pageContext) {
    if (widget._exercises.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text('Es gibt noch keine gespeicherten Übungen.'),
        ),
        floatingActionButton: _floatingButton(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Übungen"),
        actions: _actions(),
      ),
      body: ListView.builder(
        itemCount: widget._exercises.length,
        itemBuilder: (_, index) {
          Exercise e = widget._exercises.elementAt(index);
          return ListTile(
              onTap: () {
                if (_selecting) {
                  _toggleSelect(index);
                } else {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => BlocProvider(
                            create: (_) => TimerBloc(
                                e, context.bloc<SoundBloc>()),
                            child: TimerPage(),
                          )));
                }
              },
              onLongPress: () => _toggleSelect(index),
              title: Text(e.name),
              selected: _isSelected(index),
              leading: Text(e.laps.toString()),
              subtitle: Text("Interval: ${e.interval.toString()}"));
        },
      ),
      floatingActionButton: _floatingButton(),
    );
  }

  void _toggleSelect(int index) {
    if (_indexOfSelected.contains(index)) {
      _indexOfSelected.remove(index);
    } else {
      _indexOfSelected.add(index);
    }
    setState(() {});
  }
}
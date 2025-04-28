import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ketchapp_flutter/features/home/bloc/home_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';

// 1. Converti in StatefulWidget
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<IconData> _foodIcons = [
    Icons.food_bank,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.fastfood,
    Icons.cake,
    Icons.lunch_dining,
    Icons.ramen_dining,
  ];

  final CarouselSliderController _carouselController =
      CarouselSliderController();
  // Stato per tenere traccia dell'indice corrente
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    // 2. Invia l'evento per caricare i dati all'inizializzazione
    // Si assume che HomeBloc sia fornito da un BlocProvider sopra questo widget
    // Se non lo è, dovrai aggiungerne uno (es. nel router o in main.dart)
    context.read<HomeBloc>().add(LoadHomeData());
  }

  @override
  Widget build(BuildContext context) {
    // 3. Usa BlocBuilder per reagire agli stati del HomeBloc
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // 4. Mostra UI diverse in base allo stato
        if (state is HomeLoading) {
          // Mostra un indicatore di caricamento
          return const Center(child: CircularProgressIndicator());
        } else if (state is HomeLoaded) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.people, size: 100, color: Colors.blue),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      // Row per contenere freccia sx, carosello, freccia dx
                      children: [
                        // Pulsante Freccia Sinistra
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                          ), // Rimosso colore condizionale
                          onPressed:
                              () =>
                                  _carouselController
                                      .previousPage(), // Chiama sempre previousPage
                        ),
                        // Carosello
                        Expanded(
                          // Expanded per far occupare lo spazio rimanente al carosello
                          child: CarouselSlider(
                            carouselController:
                                _carouselController, // Assegna il controller
                            options: CarouselOptions(
                              height: 100.0,
                              viewportFraction:
                                  1.0, // Mostra un solo elemento completo
                              enlargeCenterPage:
                                  false, // Non necessario con viewport 1.0
                              autoPlay: false, // Disabilita auto play
                              enableInfiniteScroll:
                                  true, // <-- ABILITA loop infinito
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentCarouselIndex = index;
                                });
                              },
                            ),
                            items:
                                _foodIcons.map((iconData) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                        alignment: Alignment.center,
                                        child: Icon(
                                          iconData,
                                          size: 70.0,
                                          color: Colors.green,
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: () => _carouselController.nextPage(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Testo dinamico per l'indice
                    Text(
                      '${_currentCarouselIndex + 1}/${_foodIcons.length}', // Mostra indice corrente + 1 / totale
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.push('/plan/manual'); 
                      },
                      child: const Text('Pianifica il tuo Studio'),
                    ),
                    const SizedBox(width: 16.0), // Spazio tra i pulsanti
                    ElevatedButton(
                      onPressed: () {
                        context.push('/plan/automatic'); 
                      },
                      child: const Text('Pianifica Automatica'),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else if (state is HomeError) {
          // Mostra un messaggio di errore
          return Center(
            child: Text(
              'Errore nel caricamento: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else {
          // Gestisce lo stato iniziale (HomeInitial) o altri stati imprevisti
          // Potresti mostrare comunque un caricamento o un placeholder
          return const Center(child: Text('Inizializzazione Home...'));
        }
      },
    );
  }
}

import 'package:flutter/material.dart';

class ApartmentDescriptionWidget extends StatelessWidget {
  const ApartmentDescriptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10),
            // Description générale
            const Text(
              'Découvrez ce studio d\'exception de 27 m², situé au 3ème étage d\'une résidence sécurisée avec gardien 24/24. Ce bien, vendu entièrement meublé avec des meubles neufs, offre un cadre de vie luxueux et pratique.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            // Caractéristiques avec icônes
            featureItem(Icons.bed, 'Armoire-lit escamotable de qualité'),
            featureItem(Icons.kitchen, 'Cuisine toute neuve aménagée'),
            featureItem(Icons.shower, 'Salle de douche à l’italienne'),
            featureItem(Icons.security, 'Sécurité 24/24 avec gardien'),
            const SizedBox(height: 10),
            // Description supplémentaire
            const Text(
              'Idéal pour profiter de ses vacances. Vous serez séduit par la décoration soignée et les tons naturels qui apportent une atmosphère chaleureuse et accueillante.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            // Localisation et environnement
            const Text(
              'Situé à Cannes, ce studio est à quelques pas des célèbres marchés de la ville, où vous pourrez découvrir les saveurs locales et l\'artisanat de la région. Cannes, mondialement connue pour son festival du film, est également réputée pour sa magnifique Croisette, ses plages de sable fin, et sa vie nocturne animée.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Contact
            const Text(
              'N\'hésitez pas à me contacter pour visiter !',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget featureItem(IconData icon, String text) {
    return Row(
      children: <Widget>[
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}

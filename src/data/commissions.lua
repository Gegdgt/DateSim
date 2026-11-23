-- Costes, probabilidades y recompensas son datos; nunca viven en los botones.
return {
 {id="social_research",character="cliff",providers={"cliff"},title="Investigación social",cost=15,chance=70,refund=0,
  reward="2 copias de Escuchar O 1 libro común",outcomes={{copies={listen=2}},{items={study_book=1}}}},
 {id="enchantment_research",character="cliff",providers={"cliff"},title="Investigar encantamientos",cost=20,chance=60,refund=5,
  reward="2 materiales O 1 copia de Analizar runas",outcomes={{items={magic_material=2}},{copies={analyze_runes=1}}}},
 {id="physical_cards",character="zanoba",providers={"zanoba"},title="Fabricar cartas físicas",cost=20,chance=65,refund=0,
  reward="2 copias de Bastón O 2 de Corte sencillo",outcomes={{copies={staff_strike=2}},{copies={simple_cut=2}}}},
 {id="gather_materials",character="zanoba",providers={"zanoba","cliff"},title="Conseguir materiales",cost=15,chance=75,refund=0,
  reward="2 materiales O 1 material y 8 oro",outcomes={{items={magic_material=2}},{items={magic_material=1},gold=8}}},
}

select count(*) from traits_and_yields_view_private t left join cultivars on cultivars.id = cultivar_id where t.species_id != cultivars.specie_id;

SELECT query_to_xml('

SELECT
	s.*, array_to_string(ARRAY_AGG(DISTINCT T . ID), '', '') AS "linked_traits",
	array_to_string(ARRAY_AGG(DISTINCT y. ID), '', '') AS "linked_yields",
	array_to_string(ARRAY_AGG(DISTINCT C . ID), '', '') AS "linked_cultivars",
	array_to_string(
		ARRAY_AGG (DISTINCT ps.pft_id),
		'', ''
	) AS "linked_pfts"
FROM
	species s
LEFT JOIN traits T ON T .specie_id = s."id"
LEFT JOIN yields y ON y.specie_id = s."id"
LEFT JOIN cultivars C ON C .specie_id = s."id"
LEFT JOIN pfts_species ps ON ps.specie_id = s. ID
WHERE
	scientificname IN (
		SELECT
			scientificname
		FROM
			species
		GROUP BY
			scientificname/*,
			spcd,
			genus,
			species,
			"AcceptedSymbol",
			"SynonymSymbol",
			"Symbol",
			"PLANTS_Floristic_Area",
			"State",
			"Category",
			"Family",
			"FamilySymbol",
			"FamilyCommonName",
			"xOrder",
			"SubClass",
			"Class",
			"SubDivision",
			"Division",
			"SuperDivision",
			"SubKingdom",
			"Kingdom",
			"ITIS_TSN",
			"Duration",
			"GrowthHabit",
			"NativeStatus",
			"NationalWetlandIndicatorStatus",
			"RegionalWetlandIndicatorStatus",
			"ActiveGrowthPeriod",
			"AfterHarvestRegrowthRate",
			"Bloat",
			"C2N_Ratio",
			"CoppicePotential",
			"FallConspicuous",
			"FireResistance",
			"FoliageTexture",
			"GrowthForm",
			"GrowthRate",
			"MaxHeight20Yrs",
			"MatureHeight",
			"KnownAllelopath",
			"LeafRetention",
			"Lifespan",
			"LowGrowingGrass",
			"NitrogenFixation",
			"ResproutAbility",
			"AdaptedCoarseSoils",
			"AdaptedMediumSoils",
			"AdaptedFineSoils",
			"AnaerobicTolerance",
			"CaCO3Tolerance",
			"ColdStratification",
			"DroughtTolerance",
			"FertilityRequirement",
			"FireTolerance",
			"MinFrostFreeDays",
			"HedgeTolerance",
			"MoistureUse",
			"pH_Minimum",
			"pH_Maximum",
			"Min_PlantingDensity",
			"Max_PlantingDensity",
			"Precipitation_Minimum",
			"Precipitation_Maximum",
			"RootDepthMinimum",
			"SalinityTolerance",
			"ShadeTolerance",
			"TemperatureMinimum",
			"BloomPeriod",
			"CommercialAvailability",
			"FruitSeedPeriodBegin",
			"FruitSeedPeriodEnd",
			"Propogated_by_BareRoot",
			"Propogated_by_Bulbs",
			"Propogated_by_Container",
			"Propogated_by_Corms",
			"Propogated_by_Cuttings",
			"Propogated_by_Seed",
			"Propogated_by_Sod",
			"Propogated_by_Sprigs",
			"Propogated_by_Tubers",
			"Seeds_per_Pound",
			"SeedSpreadRate",
			"SeedlingVigor"*/
		HAVING
			COUNT (*) > 1
		AND NOT scientificname = ''''
		AND scientificname IS NOT NULL
	)
GROUP BY
	s."id"
ORDER BY
	scientificname',


    'f',
    'f',
    '');

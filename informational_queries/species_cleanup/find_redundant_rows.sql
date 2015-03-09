/* This runs too slowly to be useful.  Needs revision. */
SELECT * FROM species s1 WHERE

EXISTS(SELECT 1 FROM traits t WHERE t.specie_id = s1.id)

OR

EXISTS(SELECT 1 FROM yields y WHERE y.specie_id = s1.id)

OR

EXISTS(SELECT 1 FROM cultivars c WHERE c.specie_id = s1.id)

OR

EXISTS(SELECT 1 FROM pfts_species ps WHERE ps.specie_id = s1.id)

AND

EXISTS(SELECT 1 FROM species s2 WHERE


NOT(EXISTS(SELECT 1 FROM traits t WHERE t.specie_id = s2.id)

OR

EXISTS(SELECT 1 FROM yields y WHERE y.specie_id = s2.id)

OR

EXISTS(SELECT 1 FROM cultivars c WHERE c.specie_id = s2.id)

OR

EXISTS(SELECT 1 FROM pfts_species ps WHERE ps.specie_id = s2.id)

)

AND

s1.id != s2.id

AND



(s1."spcd" IS NULL OR s1."spcd" = s2."spcd") AND
(s1."genus" IS NULL OR s1."genus" = s2."genus") AND
(s1."species" IS NULL OR s1."species" = s2."species") AND
(s1."scientificname" IS NULL OR s1."scientificname" = s2."scientificname") AND
(s1."commonname" IS NULL OR s1."commonname" = s2."commonname") AND
(s1."notes" IS NULL OR s1."notes" = s2."notes") AND
(s1."AcceptedSymbol" IS NULL OR s1."AcceptedSymbol" = s2."AcceptedSymbol") AND
(s1."SynonymSymbol" IS NULL OR s1."SynonymSymbol" = s2."SynonymSymbol") AND
(s1."Symbol" IS NULL OR s1."Symbol" = s2."Symbol") AND
(s1."PLANTS_Floristic_Area" IS NULL OR s1."PLANTS_Floristic_Area" = s2."PLANTS_Floristic_Area") AND
(s1."State" IS NULL OR s1."State" = s2."State") AND
(s1."Category" IS NULL OR s1."Category" = s2."Category") AND
(s1."Family" IS NULL OR s1."Family" = s2."Family") AND
(s1."FamilySymbol" IS NULL OR s1."FamilySymbol" = s2."FamilySymbol") AND
(s1."FamilyCommonName" IS NULL OR s1."FamilyCommonName" = s2."FamilyCommonName") AND
(s1."xOrder" IS NULL OR s1."xOrder" = s2."xOrder") AND
(s1."SubClass" IS NULL OR s1."SubClass" = s2."SubClass") AND
(s1."Class" IS NULL OR s1."Class" = s2."Class") AND
(s1."SubDivision" IS NULL OR s1."SubDivision" = s2."SubDivision") AND
(s1."Division" IS NULL OR s1."Division" = s2."Division") AND
(s1."SuperDivision" IS NULL OR s1."SuperDivision" = s2."SuperDivision") AND
(s1."SubKingdom" IS NULL OR s1."SubKingdom" = s2."SubKingdom") AND
(s1."Kingdom" IS NULL OR s1."Kingdom" = s2."Kingdom") AND
(s1."ITIS_TSN" IS NULL OR s1."ITIS_TSN" = s2."ITIS_TSN") AND
(s1."Duration" IS NULL OR s1."Duration" = s2."Duration") AND
(s1."GrowthHabit" IS NULL OR s1."GrowthHabit" = s2."GrowthHabit") AND
(s1."NativeStatus" IS NULL OR s1."NativeStatus" = s2."NativeStatus") AND
(s1."NationalWetlandIndicatorStatus" IS NULL OR s1."NationalWetlandIndicatorStatus" = s2."NationalWetlandIndicatorStatus") AND
(s1."RegionalWetlandIndicatorStatus" IS NULL OR s1."RegionalWetlandIndicatorStatus" = s2."RegionalWetlandIndicatorStatus") AND
(s1."ActiveGrowthPeriod" IS NULL OR s1."ActiveGrowthPeriod" = s2."ActiveGrowthPeriod") AND
(s1."AfterHarvestRegrowthRate" IS NULL OR s1."AfterHarvestRegrowthRate" = s2."AfterHarvestRegrowthRate") AND
(s1."Bloat" IS NULL OR s1."Bloat" = s2."Bloat") AND
(s1."C2N_Ratio" IS NULL OR s1."C2N_Ratio" = s2."C2N_Ratio") AND
(s1."CoppicePotential" IS NULL OR s1."CoppicePotential" = s2."CoppicePotential") AND
(s1."FallConspicuous" IS NULL OR s1."FallConspicuous" = s2."FallConspicuous") AND
(s1."FireResistance" IS NULL OR s1."FireResistance" = s2."FireResistance") AND
(s1."FoliageTexture" IS NULL OR s1."FoliageTexture" = s2."FoliageTexture") AND
(s1."GrowthForm" IS NULL OR s1."GrowthForm" = s2."GrowthForm") AND
(s1."GrowthRate" IS NULL OR s1."GrowthRate" = s2."GrowthRate") AND
(s1."MaxHeight20Yrs" IS NULL OR s1."MaxHeight20Yrs" = s2."MaxHeight20Yrs") AND
(s1."MatureHeight" IS NULL OR s1."MatureHeight" = s2."MatureHeight") AND
(s1."KnownAllelopath" IS NULL OR s1."KnownAllelopath" = s2."KnownAllelopath") AND
(s1."LeafRetention" IS NULL OR s1."LeafRetention" = s2."LeafRetention") AND
(s1."Lifespan" IS NULL OR s1."Lifespan" = s2."Lifespan") AND
(s1."LowGrowingGrass" IS NULL OR s1."LowGrowingGrass" = s2."LowGrowingGrass") AND
(s1."NitrogenFixation" IS NULL OR s1."NitrogenFixation" = s2."NitrogenFixation") AND
(s1."ResproutAbility" IS NULL OR s1."ResproutAbility" = s2."ResproutAbility") AND
(s1."AdaptedCoarseSoils" IS NULL OR s1."AdaptedCoarseSoils" = s2."AdaptedCoarseSoils") AND
(s1."AdaptedMediumSoils" IS NULL OR s1."AdaptedMediumSoils" = s2."AdaptedMediumSoils") AND
(s1."AdaptedFineSoils" IS NULL OR s1."AdaptedFineSoils" = s2."AdaptedFineSoils") AND
(s1."AnaerobicTolerance" IS NULL OR s1."AnaerobicTolerance" = s2."AnaerobicTolerance") AND
(s1."CaCO3Tolerance" IS NULL OR s1."CaCO3Tolerance" = s2."CaCO3Tolerance") AND
(s1."ColdStratification" IS NULL OR s1."ColdStratification" = s2."ColdStratification") AND
(s1."DroughtTolerance" IS NULL OR s1."DroughtTolerance" = s2."DroughtTolerance") AND
(s1."FertilityRequirement" IS NULL OR s1."FertilityRequirement" = s2."FertilityRequirement") AND
(s1."FireTolerance" IS NULL OR s1."FireTolerance" = s2."FireTolerance") AND
(s1."MinFrostFreeDays" IS NULL OR s1."MinFrostFreeDays" = s2."MinFrostFreeDays") AND
(s1."HedgeTolerance" IS NULL OR s1."HedgeTolerance" = s2."HedgeTolerance") AND
(s1."MoistureUse" IS NULL OR s1."MoistureUse" = s2."MoistureUse") AND
(s1."pH_Minimum" IS NULL OR s1."pH_Minimum" = s2."pH_Minimum") AND
(s1."pH_Maximum" IS NULL OR s1."pH_Maximum" = s2."pH_Maximum") AND
(s1."Min_PlantingDensity" IS NULL OR s1."Min_PlantingDensity" = s2."Min_PlantingDensity") AND
(s1."Max_PlantingDensity" IS NULL OR s1."Max_PlantingDensity" = s2."Max_PlantingDensity") AND
(s1."Precipitation_Minimum" IS NULL OR s1."Precipitation_Minimum" = s2."Precipitation_Minimum") AND
(s1."Precipitation_Maximum" IS NULL OR s1."Precipitation_Maximum" = s2."Precipitation_Maximum") AND
(s1."RootDepthMinimum" IS NULL OR s1."RootDepthMinimum" = s2."RootDepthMinimum") AND
(s1."SalinityTolerance" IS NULL OR s1."SalinityTolerance" = s2."SalinityTolerance") AND
(s1."ShadeTolerance" IS NULL OR s1."ShadeTolerance" = s2."ShadeTolerance") AND
(s1."TemperatureMinimum" IS NULL OR s1."TemperatureMinimum" = s2."TemperatureMinimum") AND
(s1."BloomPeriod" IS NULL OR s1."BloomPeriod" = s2."BloomPeriod") AND
(s1."CommercialAvailability" IS NULL OR s1."CommercialAvailability" = s2."CommercialAvailability") AND
(s1."FruitSeedPeriodBegin" IS NULL OR s1."FruitSeedPeriodBegin" = s2."FruitSeedPeriodBegin") AND
(s1."FruitSeedPeriodEnd" IS NULL OR s1."FruitSeedPeriodEnd" = s2."FruitSeedPeriodEnd") AND
(s1."Propogated_by_BareRoot" IS NULL OR s1."Propogated_by_BareRoot" = s2."Propogated_by_BareRoot") AND
(s1."Propogated_by_Bulbs" IS NULL OR s1."Propogated_by_Bulbs" = s2."Propogated_by_Bulbs") AND
(s1."Propogated_by_Container" IS NULL OR s1."Propogated_by_Container" = s2."Propogated_by_Container") AND
(s1."Propogated_by_Corms" IS NULL OR s1."Propogated_by_Corms" = s2."Propogated_by_Corms") AND
(s1."Propogated_by_Cuttings" IS NULL OR s1."Propogated_by_Cuttings" = s2."Propogated_by_Cuttings") AND
(s1."Propogated_by_Seed" IS NULL OR s1."Propogated_by_Seed" = s2."Propogated_by_Seed") AND
(s1."Propogated_by_Sod" IS NULL OR s1."Propogated_by_Sod" = s2."Propogated_by_Sod") AND
(s1."Propogated_by_Sprigs" IS NULL OR s1."Propogated_by_Sprigs" = s2."Propogated_by_Sprigs") AND
(s1."Propogated_by_Tubers" IS NULL OR s1."Propogated_by_Tubers" = s2."Propogated_by_Tubers") AND
(s1."Seeds_per_Pound" IS NULL OR s1."Seeds_per_Pound" = s2."Seeds_per_Pound") AND
(s1."SeedSpreadRate" IS NULL OR s1."SeedSpreadRate" = s2."SeedSpreadRate") AND
(s1."SeedlingVigor" IS NULL OR s1."SeedlingVigor" = s2."SeedlingVigor")

);

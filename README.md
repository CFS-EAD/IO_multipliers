## IO\_multipliers

[GitHub repository](https://github.com/CFS-EAD/IO_multipliers) serving
to:

1.  Download and extract custom Forest Sector input-output multipliers
    (StatCan 2023) from
    [GCDocs](https://gcdocs.gc.ca/nrcan-rncan/llisapi.dll?func=ll&objId=87876987&objAction=browse&viewType=1#)
    via
    [EAD\_SilvaCloud](https://drive.google.com/drive/folders/0AD8y6eREp30cUk9PVA)
    (Google Workspace)

    -   [R/00\_global.R](https://github.com/CFS-EAD/IO_multipliers/blob/main/R/00_global.R)
    -   [R/01\_dataPrep.R](https://github.com/CFS-EAD/IO_multipliers/blob/main/R/01_dataPrep.R)

2.  Calculate subsector-specific conversion factors (m3 to Output $)
    corresponding to direct, indirect, induced and total multipliers
    (constrained & unconstrained) for applicable provincial and
    territorial jurisdictions

    -   [R/02\_IO\_tables.R](https://github.com/CFS-EAD/IO_multipliers/blob/main/R/02_IO_tables.R)
    -   [R/03\_volume2output\_conversion.R](https://github.com/CFS-EAD/IO_multipliers/blob/main/R/03_volume2output_conversion.R)

3.  Write summary tables to file for subsequent use in SE impacts
    estimation

    -   [output/IO\_conversion\_factors\_2021.csv](https://github.com/CFS-EAD/IO_multipliers/blob/main/output/IO_conversion_factors_2021.csv)
    -   [output/IO\_tables\_2021.csv](https://github.com/CFS-EAD/IO_multipliers/blob/main/output/IO_tables_2021.csv)

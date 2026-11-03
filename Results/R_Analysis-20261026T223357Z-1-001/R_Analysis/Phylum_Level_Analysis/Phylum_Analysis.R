# ============================================================
# Phylum-Level Relative Abundance - Individual Samples
# ============================================================

# Load required libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)


# STEP 1: Import the merged MetaPhlAn abundance table
dataFORtxon <- read.delim(
  "/Users/shahadhamad/Downloads/merged_abundance_table.tsv",
  header = TRUE,
  skip = 1,
  check.names = FALSE
)

# Check the imported data
head(dataFORtxon)
colnames(dataFORtxon)


# STEP 2: Extract Phylum-level taxa
phylum_data <- dataFORtxon %>%
  filter(str_detect(clade_name, "^k__[^|]+\\|p__[^|]+$")) %>%
  mutate(
    Phylum = str_remove(
      str_extract(clade_name, "p__[^|]+"),
      "^p__"
    )
  ) %>%
  select(-clade_name) %>%
  pivot_longer(
    cols = -Phylum,
    names_to = "Sample",
    values_to = "Abundance"
  ) %>%
  mutate(Abundance = as.numeric(Abundance)) %>%
  group_by(Sample, Phylum) %>%
  summarise(
    Abundance = sum(Abundance),
    .groups = "drop"
  )

# Check the number of Phylum-level categories
print(n_distinct(phylum_data$Phylum))
print(sort(unique(phylum_data$Phylum)))


# STEP 3: Extract UNCLASSIFIED abundance
unclassified_data <- dataFORtxon %>%
  filter(clade_name == "UNCLASSIFIED") %>%
  select(-clade_name) %>%
  pivot_longer(
    cols = everything(),
    names_to = "Sample",
    values_to = "Abundance"
  ) %>%
  mutate(
    Phylum = "UNCLASSIFIED",
    Abundance = as.numeric(Abundance)
  ) %>%
  select(Sample, Phylum, Abundance)

# Check that the UNCLASSIFIED row exists
if (nrow(unclassified_data) == 0) {
  stop("UNCLASSIFIED row was not found in the input table.")
}


# STEP 4: Combine Phylum and UNCLASSIFIED data
phylum_final <- bind_rows(
  phylum_data,
  unclassified_data
)

# Check total relative abundance per sample
abundance_check <- phylum_final %>%
  group_by(Sample) %>%
  summarise(
    Total_Abundance = sum(Abundance),
    .groups = "drop"
  )

print(abundance_check)

# Warn if totals differ substantially from 100%
if (any(abs(abundance_check$Total_Abundance - 100) > 0.1)) {
  warning(
    "Some sample totals are not close to 100%. ",
    "Check the original taxonomy table before interpreting the plot."
  )
}

# STEP 5: Define a consistent color palette for taxonomic categoriesphylum_colors <- c(
phylum_colors <- c(
  "Bacteroidota" = "#329DD8",
  "Firmicutes" = "#8CC5E8",
  "Pseudomonadota" = "#B83E59",
  "Actinomycetota" = "#E99A55",
  "Fusobacteriota" = "#9569C7",
  "Verrucomicrobiota" = "#F3A47F",
  "Lentisphaerota" = "#E2B74B",
  "Thermodesulfobacteriota" = "#D879B5",
  "Candidatus_Melainabacteria" = "#6C85D9",
  "Candidatus_Saccharibacteria" = "#BD8CB9",
  "Bacteria_unclassified" = "#6BC5D9",
  "UNCLASSIFIED" = "#D9DDE3"
)

# Verify that every category has a defined color
missing_colors <- setdiff(
  unique(phylum_final$Phylum),
  names(phylum_colors)
)

if (length(missing_colors) > 0) {
  stop(
    "Missing colors for: ",
    paste(missing_colors, collapse = ", ")
  )
}


# STEP 6: Create the stacked bar chart

# Define sample labels with group names
sample_labels <- c(
  "SRR29930198" = "198\nHealthy",
  "SRR29930199" = "199\nHealthy",
  "SRR29930206" = "206\nCRC",
  "SRR29930207" = "207\nCRC",
  "SRR29930208" = "208\nCRC",
  "SRR29930209" = "209\nCRC"
)

plot1 <- ggplot(
  phylum_final,
  aes(x = Sample, y = Abundance, fill = Phylum)
) +
  geom_col(width = 0.75) +
  scale_fill_manual(values = phylum_colors) +
  scale_x_discrete(labels = sample_labels) +
  scale_y_continuous(
    breaks = seq(0, 100, 20),
    expand = c(0, 0)
  ) +
  coord_cartesian(ylim = c(0, 100)) +
  labs(
    title = "Phylum-Level Relative Abundance Across Individual Samples",
    x = "Sample",
    y = "Relative Abundance (%)",
    fill = "Phylum"
  ) +
  theme_bw(base_size = 10) +
  theme(
    plot.title = element_text(size = 12, face = "bold"),
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = 8),
    legend.text = element_text(size = 11),
    legend.key.size = grid::unit(0.55, "cm")
  )

# STEP 7: Display the graph
print(plot1)


# STEP 8: Save the graph as a high-resolution PNG
ggsave("Phylum_Blue_Red_Theme3.png", plot1,
       width = 10, height = 6, dpi = 300)


# ============================================================
# Phylum-Level Relative Abundance - Healthy vs CRC
# ============================================================


# Assign samples to Healthy and CRC groups
group_data <- phylum_final %>%
  mutate(
    Group = case_when(
      Sample %in% c("SRR29930198", "SRR29930199") ~ "Healthy",
      Sample %in% c(
        "SRR29930206",
        "SRR29930207",
        "SRR29930208",
        "SRR29930209"
      ) ~ "CRC",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(Group))

# Calculate mean relative abundance for each group
group_mean <- group_data %>%
  group_by(Group, Phylum) %>%
  summarise(
    Abundance = mean(Abundance),
    .groups = "drop"
  ) %>%
  mutate(Group = factor(Group, levels = c("Healthy", "CRC")))

# Plot phylum-level relative abundance by group
plot2 <- ggplot(
  group_mean,
  aes(x = Group, y = Abundance, fill = Phylum)
) +
  geom_col(width = 0.35) +
  scale_fill_manual(values = phylum_colors) +
  scale_y_continuous(
    breaks = seq(0, 100, 20),
    expand = c(0, 0)
  ) +
  coord_cartesian(ylim = c(0, 100)) +
  labs(
    title = "Phylum-Level Relative Abundance: Healthy vs CRC",
    x = "Group",
    y = "Mean Relative Abundance (%)",
    fill = "Phylum"
  ) +
  theme_bw(base_size = 11) +
  theme(
    plot.title = element_text(size = 12, face = "bold"),
    axis.text.x = element_text(size = 11),
    legend.text = element_text(size = 10),
    legend.key.size = grid::unit(0.35, "cm")
  )

# Display the plot
print(plot2)

# Save the plot
ggsave(
  "Phylum_Healthy_vs_CRC1.png",
  plot2,
  width = 10,
  height = 6,
  dpi = 300
)

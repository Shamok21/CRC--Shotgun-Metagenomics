# Create sample metadata
sample_metadata <- data.frame(
  Sample = c(
    "SRR29930198",
    "SRR29930199",
    "SRR29930206",
    "SRR29930207",
    "SRR29930208",
    "SRR29930209"
  ),
  Group = c(
    "Healthy",
    "Healthy",
    "CRC",
    "CRC",
    "CRC",
    "CRC"
  )
)

# Select the top 15 genera and sample columns only
group_data <- top_genera[, c("Genus", sample_cols)]

# Convert from wide format to long format
group_data_long <- pivot_longer(
  group_data,
  cols = all_of(sample_cols),
  names_to = "Sample",
  values_to = "Relative_Abundance"
)

# Add group information to each sample
group_data_long <- left_join(
  group_data_long,
  sample_metadata,
  by = "Sample"
)

# Calculate mean abundance for each genus in each group
group_summary <- group_data_long %>%
  group_by(Genus, Group) %>%
  summarise(
    Mean_Abundance = mean(Relative_Abundance),
    .groups = "drop"
  )

ggplot(
  group_summary,
  aes(
    x = Genus,
    y = Mean_Abundance,
    fill = Group
  )
) +
  
  geom_col(position = "dodge") +
  
  scale_fill_manual(
    values = c(
      "CRC" = "#D73027",
      "Healthy" = "#2166AC"
    )
  ) +
  
  labs(
    title = "Genus-Level Relative Abundance by Group",
    x = "Genus",
    y = "Mean Relative Abundance (%)",
    fill = "Group"
  ) +
  
  theme_bw() +
  
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold",
      size = 14
    ),
    axis.text.x = element_text(
      angle = 45,
      hjust = 1,
      size = 9
    ),
    axis.title = element_text(face = "bold"),
    legend.position = "right"
  )

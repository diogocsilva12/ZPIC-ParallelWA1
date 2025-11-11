library(ggplot2)
library(ggpubr)

times <- c(577.14, 248.14, 214.5, 60.83)
opt_levels <- c("No optimization", "O2", "O3", "Ofast")
df <- data.frame(opt_levels, times)
df$speedup <- df$times[1] / df$times

# Subtle, professional color palette
palette <- c("#b0c4de", "#80b1d3", "#4f9ac9", "#2171b5")

p <- ggbarplot(df,
               x = "opt_levels",
               y = "times",
               fill = "opt_levels",
               color = "black",
               palette = palette,
               label = sprintf("%.1f s", df$times),
               lab.pos = "out",
               lab.size = 3.8,
               width = 0.55) +  # thinner bars
  labs(
    title = "Execution Time vs Compiler Optimization Level",
    subtitle = "Measured on A64FX (Deucalion, 1 node, 1 core)",
    x = "Optimization Level",
    y = "Execution Time (s)"
  ) +
  theme_pubclean() +
  theme(
    text = element_text(size = 12, family = ""),
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray40"),
    axis.title = element_text(size = 13, face = "bold"),
    axis.text = element_text(size = 11),
    legend.position = "none",
    panel.grid.major.y = element_line(color = "gray90"),
    panel.grid.minor = element_blank(),
    plot.margin = margin(10, 20, 10, 10)
  ) +
  geom_text(aes(label = paste0("×", round(speedup, 1), " faster")),
            vjust = -2.2,
            size = 3.5,
            color = "gray25") +
  expand_limits(y = max(df$times) * 1.18)

p

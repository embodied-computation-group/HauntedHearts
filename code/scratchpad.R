

```{r}
p1 <- ggplot(data = haunted_data, aes ( x = (-PsiSlope)+max(PsiSlope), y = pre_RateScared, fill =MeanBPM )) +
  scale_fill_viridis_b()+  
  theme_cowplot()+
  geom_smooth(method = "lm")+
  ylab("Baseline Fear")+
  xlab("Interoceptive Precision")+
  geom_point(shape = 21)


p1 <- ggplot(data = haunted_data, aes ( x = (PsiSlope), y = pre_RateScared, fill =MaxBPM )) +
  scale_fill_viridis_b()+  
  theme_cowplot()+
  geom_smooth(method = "lm")+
  ylab("Baseline Fear")+
  xlab("Interoceptive Precision")+
  geom_point(shape = 21)


p2 <- ggplot(data = haunted_data, aes ( x = PsiThreshold, y = pre_RateScared, fill =MaxBPM )) +
  scale_fill_viridis_b()+  
  theme_cowplot()+
  geom_smooth(method = "lm")+
  ylab("Baseline Fear")+
  xlab("Interoceptive Bias")+
  geom_point(shape = 21)


p3 <- ggplot(data = haunted_data, aes ( x = d, y =  pre_RateScared, fill =MaxBPM )) +
  scale_fill_viridis_b()+  
  theme_cowplot()+
  geom_smooth(method = "lm")+
  ylab("Baseline Fear")+
  xlab("Interoceptive Sensitivity")+
  geom_point(shape = 21)

tp <- p1+p2+p3 + plot_layout(guides = "collect")

tp

ggsave(here("figs", "scatter_baseline_fear.png"), height = 1200, width = 2400, dpi = 150, units = "px")


```



```{r}




ggsave(here("figs", "surveyResults.png"), height = 6, width = 12, dpi = 150, units = "in")

```
Scraps

```{r}

p1 <- ggplot(data = haunted_data, aes ( x = (1-PsiSlope)+max(PsiSlope), y = pre_SympSum, fill =MaxBPM )) +
  scale_fill_viridis_b()+  
  theme_cowplot()+
  geom_smooth(method = "lm")+
  ylab("Baseline Somatic Anxiety")+
  xlab("Interoceptive Precision")+
  geom_point(shape = 21)


p2 <- ggplot(data = haunted_data, aes ( x = PsiThreshold, y = pre_SympSum, fill =MaxBPM )) +
  scale_fill_viridis_b()+  
  theme_cowplot()+
  geom_smooth(method = "lm")+
  ylab("Baseline Somatic Anxiety")+
  xlab("Interoceptive Bias")+
  geom_point(shape = 21)


p3 <- ggplot(data = haunted_data, aes ( x = d, y = pre_SympSum, fill =MaxBPM )) +
  scale_fill_viridis_b()+  
  theme_cowplot()+
  geom_smooth(method = "lm")+
  ylab("Baseline Somatic Anxiety")+
  xlab("Interoceptive Sensitivity")+
  geom_point(shape = 21)
```


```{r}

mat_data <- haunted_data %>%
  select(matches(".Symp.")) %>%
  pivot_longer(cols = everything(), 
               names_sep = "_", 
               names_to = c("Time", "Measure"),
               values_to = "Rating") %>%
  group_by(Time, Measure)  %>%
  filter(Measure != "SympSum") %>%
  filter(Rating < 4)



summary_data <- mat_data %>%
  summarise(meanRating = mean(Rating, na.rm=TRUE), 
            sdRating = sd(Rating, na.rm=TRUE), 
            num = n()) %>%
  mutate(seRating = sdRating/sqrt(num))

mat_data$Time <- factor(mat_data$Time,levels=c("pre","post"))
summary_data$Time <- factor(summary_data$Time,levels=c("pre","post"))

dodge <- position_dodge(width=0.9)
p1<-ggplot(data = summary_data, aes(x = Measure, y = meanRating, fill = Time)) +
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin = meanRating-seRating, ymax =  meanRating+seRating, fill = Time),
                position =dodge, width = 0.2) +
  scale_x_discrete(labels=c(
    "SympBreathing" = "Breathing", "SympDizzy" = "Dizzy", "SympNoRelax" ="Tense", "SympRapidHB" = "Heartbeat", "SympShaky" = "Shaky", "SympSum" = "Sum"))+
  scale_fill_manual(values = c("#E7B800", "#FC4E07"))+
  scale_y_continuous(limits = c(0,3), breaks=c(0, 1, 2, 3)) +
  ylab("Mean Rating") +
  theme_cowplot() +
  theme(legend.position = "top") +
  ggtitle("Change in Symptoms")

#geom_boxplot()

p1
ggsave(here("figs", "boxplot_time_fear.jpeg"), height = 4, width = 6, dpi = 150, units = "in")



```



```{r}


#+
#+
#geom_boxjitter(notch = TRUE, width = .5, jitter.shape = 21, outlier.shape = NA, height = 0) +
scale_fill_manual(values = c("#E7B800", "#FC4E07")) +
  theme_cowplot()+
  facet_wrap(~Measure, scales = "free", 
             labeller = as_labeller(c(RateScared = "Rating", SympSum = "Sum of Symptoms")),
             strip.position = "left")+
  theme(
    strip.background = element_blank(),
    strip.placement = "outside",
    legend.position = "top") +
  scale_x_discrete(labels=c(
    "RateScared" = "Fear",  "SympSum" = "Somatic Anxiety")) +
  ylab(NULL) +
  ggtitle("Fear and Somatic Anxiety")
p1

### Individual STICSA Propotional Bar Plot 

mat_data$Rating <- factor(mat_data$Rating )
mat_data$Time <- factor(mat_data$Time,levels=c("pre","post"))
p2 <- ggplot(data = mat_data, aes(y = Measure, fill = factor(Rating))) +
  geom_bar(aes(fill = Rating), position = position_fill(reverse = TRUE)) +
  scale_fill_manual(values=c("#151515FF", "#A6A6A6FF","#C0C3C6FF", "#EA5F21FF", "#F6FAFDFF"), 
                    name="Rating",
                    breaks=c("0", "1", "2", "3"),
                    labels=c("1", "2", "3", "4"))+
  scale_y_discrete(labels=c(
    "SympBreathing" = "Breathing", "SympDizzy" = "Dizzy", "SympNoRelax" ="Tense", "SympRapidHB" = "Heartbeat", "SympShaky" = "Shaky", "SympSum" = "Sum"))+
  theme_cowplot() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        legend.position = "top")+
  xlab("Proportion of Responses") +
  scale_x_continuous(labels = scales::percent_format(accuracy = 1))+
  facet_grid(Time~.) +
  ggtitle("Item-Level Responses")


## plotting and saving 

```

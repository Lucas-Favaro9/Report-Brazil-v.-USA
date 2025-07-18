# Setting the environment
setwd("C:/Users/Lucas/Downloads")

# Uploading packages
library(tidyverse)
library(readxl)
library(magrittr)
library(showtext)
library(sysfonts)
library(stringr)
library(scales)
library(grid)

# Code to showcase graphs in Calibri font
font_add(family = "calibri", regular = "calibri.ttf")
showtext_auto()

## 1ST EXERCISE - GRAPH OF TRADE BALANCE ----

# Importing data
geral <- read_excel('comercio geral.xlsx')

# Calculating trade balance
saldo <- geral %>%
  group_by(Ano) %>%
  summarise(Saldo = sum(ifelse(Fluxo == "Exportação", Valor, -Valor)) / 10^9)

# Graph
ggplot(saldo, aes(x = Ano, y = Saldo)) +
  geom_line(color = "steelblue", size = 1) +
  geom_point(color = "steelblue", size = 2) +
  geom_hline(yintercept = 0, size = .3) +
  scale_x_continuous(breaks = seq(from = 2000, to = 2025, by = 5),
                     limits = c(2000,2025)) +
  labs(x = "", y = "Trade balance (US$ billion)") +
  theme_minimal(base_family = "calibri") +
  theme(axis.text = element_text(size = 45),
        axis.title = element_text(size = 50))

ggsave(plot = last_plot(), file = "saldo.png", width = 10, height = 5, bg = 'white')

## 2RD EXERCISE - EXPORTS BY REGIONS ----

# Importing data
regiao <- read_excel('comercio regiao.xlsx') %>%
  select(-País) %>%
  filter(`UF do Município` != "Não Declarada",
         `UF do Município` != "Exterior")

# Pivoting
regiao_pivot <- regiao %>%
  pivot_longer(cols = -`UF do Município`,
               names_to = "Ano", values_to = "Valor") %>%
  mutate(Valor = Valor / 10^9,
         Região = case_when(
           `UF do Município` %in% c("Acre", "Amapá", "Amazonas", "Pará", "Rondônia", "Roraima", "Tocantins") ~ "North",
           `UF do Município` %in% c("Alagoas", "Bahia", "Ceará", "Maranhão", "Paraíba", "Pernambuco", "Piauí", "Rio Grande do Norte", "Sergipe") ~ "Northeast",
           `UF do Município` %in% c("Distrito Federal", "Goiás", "Mato Grosso", "Mato Grosso do Sul") ~ "Central-West",
           `UF do Município` %in% c("Espírito Santo", "Minas Gerais", "Rio de Janeiro", "São Paulo") ~ "Southeast",
           `UF do Município` %in% c("Paraná", "Rio Grande do Sul", "Santa Catarina") ~ "South",
           TRUE ~ NA_character_))

# Finding the share of exports of each region
grupo <- regiao_pivot %>%
  group_by(Ano, Região) %>%
  summarize(Valor = sum(Valor)) %>%
  mutate(Ano = as.numeric(str_remove(Ano, " - Valor US\\$ FOB$")))

# Graph
ggplot(grupo, aes(x = Ano, y = Valor, color = Região)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  labs(x = "",
       y = "Export value (US$ billion)",
       color = "") +
  theme_minimal(base_family = "calibri") +
  theme(axis.text = element_text(size = 45),
        axis.title = element_text(size = 50),
        legend.text = element_text(size = 50))

ggsave(plot = last_plot(), file = "região.png", width = 10, height = 5, bg = 'white')
  
## 3RD EXERCISE - GRAPH OF MAIN STATE EXPORTERS ----

# Importing data
estado <- read_excel('comercio estado.xlsx') %>%
  filter(Fluxo == 'Exportação') %>%
  mutate(Percentual = Valor / sum(Valor) * 100,
         Valor = Valor / 10^9) %>%
  filter(`UF do Produto` != "Não Declarada") %>%
  mutate(Região = case_when(
           `UF do Produto` %in% c("Acre", "Amapá", "Amazonas", "Pará", "Rondônia", "Roraima", "Tocantins") ~ "North",
           `UF do Produto` %in% c("Alagoas", "Bahia", "Ceará", "Maranhão", "Paraíba", "Pernambuco", "Piauí", "Rio Grande do Norte", "Sergipe") ~ "Northeast",
           `UF do Produto` %in% c("Distrito Federal", "Goiás", "Mato Grosso", "Mato Grosso do Sul") ~ "Central-West",
           `UF do Produto` %in% c("Espírito Santo", "Minas Gerais", "Rio de Janeiro", "São Paulo") ~ "Southeast",
           `UF do Produto` %in% c("Paraná", "Rio Grande do Sul", "Santa Catarina") ~ "South",
           TRUE ~ NA_character_))

# Graph
ggplot(estado, aes(x = reorder(`UF do Produto`, Percentual), y = Percentual, fill = Região)) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(breaks = seq(from = 0, to = 35, by = 5),
                     limits = c(0,35)) +
  labs(x = "", y = "Share of exports (%)", fill = "") +
  theme_minimal(base_family = "calibri") +
  theme(axis.text = element_text(size = 45),
        axis.title = element_text(size = 50),
        legend.text = element_text(size = 50))

ggsave(plot = last_plot(), file = "estados.png", width = 10, height = 5, bg = 'white')

## 4TH EXERCISE - GRAPH OF MAIN PRODUCTS ----

# Importing and arranging data
produto <- read_excel('comercio produto.xlsx') %>%
  arrange(desc(Valor)) %>%
  head(10) %>%
  mutate(Valor = Valor / 10^9,
         `Descrição SH2` = recode(
           `Descrição SH2`,
           # 1
           "Combustíveis minerais, óleos minerais e produtos da sua destilação; matérias betuminosas; ceras minerais" =
             "Mineral fuels and oils",
           # 2
           "Ferro fundido, ferro e aço" =
             "Iron and steel",
           # 3
           "Reatores nucleares, caldeiras, máquinas, aparelhos e instrumentos mecânicos, e suas partes" =
             "Mechanical machinery and equipment",
           # 4
           "Aeronaves e aparelhos espaciais, e suas partes" =
             "Aircraft and its parts",
           # 5
           "Café, chá, mate e especiarias" =
             "Coffee, tea and spices",
           # 6
           "Pastas de madeira ou de outras matérias fibrosas celulósicas; papel ou cartão para reciclar (desperdícios e aparas)." =
             "Wood pulp and recycled paper",
           # 7
           "Madeira, carvão vegetal e obras de madeira" =
             "Wood and wood articles",
           # 8
           "Máquinas, aparelhos e materiais elétricos, e suas partes; aparelhos de gravação ou de reprodução de som, aparelhos de gravação ou de reprodução de imagens e de som em televisão, e suas partes e acessórios" =
             "Electrical machinery and equipment",
           # 9
           "Preparações de produtos hortícolas, de frutas ou de outras partes de plantas" =
             "Vegetable preparations and preserves",
           # 10
           "Carnes e miudezas, comestíveis" =
             "Meat and edible offal"),
         `Descrição SH2` = factor(`Descrição SH2`, levels = `Descrição SH2`))

# Graph
ggplot(produto, aes(x = reorder(`Descrição SH2`, Valor), y = Valor)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(x = "", 
    y = "Export value (US$ billion)") +
  theme_minimal(base_family = "calibri") +
  theme(axis.text = element_text(size = 45),
        axis.title = element_text(size = 50))

ggsave(plot = last_plot(), file = "produto.png", width = 10, height = 5, bg = 'white')

## 5TH EXERCISE - MAP BY PRODUCTS ----

# Importing data
produto_estado <- read_excel('comercio produto estado 2.xlsx') %>%
  filter(`UF do Produto` != "Não Declarada")

# Selecting the most exported product by state
teste <- produto_estado %>%
  group_by(`UF do Produto`) %>%
  slice_max(order_by = Valor, n = 1, with_ties = T) %>%
  ungroup()

# Creating object of each HS2
traducoes <- c(
  "Produtos do reino vegetal" = "Vegetable products",
  "Produtos das indútrias alimentares; Bebidas, líquidos alcoólicos e vinagres; Tabaco e seus sucedâneos manufaturados" = "Food, beverages and tobacco",
  "Máquinas e aparelhos, material elétrico e suas partes; Aparelhos de gravação ou reprodução de som, aparelhos de gravação ou reprodução de imagens e de som em televisão, e suas partes e acessórios" = "Machinery and electronics",
  "Pastas de madeira ou de outras matérias fibrosas celulósicas; Papel ou cartão para reciclar (desperdícios e aparas); Papel e suas obras" = "Pulp, paper and products",
  "Metais comuns e suas obras" = "Base metals and articles",
  "Gorduras e óleos animais ou vegetais; Produtos da sua dossociação; Gorduras alimentares elaboradas; Ceras de origem animal ou vegetal" = "Animal/vegetable fats and waxes",
  "Animais vivos e produtos do reino animal" = "Live animals and animal products",
  "Madeira, carvão vegetal e obras de madeira; Cortiça e suas obras; Obras de espartaria ou de cestaria" = "Wood, cork and basketry",
  "Produtos das indústrias químicas ou indústrias conexas" = "Chemical products",
  "Produtos minerais" = "Mineral products",
  "Material de transporte" = "Transport equipment")

# Inserting the translations
teste %<>% mutate(`Descrição Seção` = recode(`Descrição Seção`, !!!traducoes))

# Loading necessary packages
library(geobr)
library(sf)

# Loading the state polygon
estados_sf <- read_state(year = 2020) %>%
  # Adjusting some names to make the join
  mutate(name_state = recode(name_state,
                             "Amazônas" = "Amazonas",
                             "Rio Grande Do Norte" = "Rio Grande do Norte",
                             "Rio De Janeiro" = "Rio de Janeiro",
                             "Rio Grande Do Sul" = "Rio Grande do Sul",
                             "Mato Grosso Do Sul" = "Mato Grosso do Sul"))

# Merging the results and map dataframes
mapa <- estados_sf %>%
  left_join(teste, by = c("name_state" = "UF do Produto")) %>%
  mutate(name_region = case_when(
    name_region == "Norte" ~ "North",
    name_region == "Nordeste" ~ "Northeast",
    name_region == "Centro Oeste" ~ "Central-West",
    name_region == "Sudeste" ~ "Southeast",
    name_region == "Sul" ~ "South",
    T ~ name_region))

# South and Southeast
mapa1 <- mapa %>%
  filter(name_region %in% c("South", "Southeast", "Central-West"))

# Map
ggplot(mapa1) +
  geom_sf(aes(fill = `Descrição Seção`), color = "white", size  = 0.2) +
  labs(fill  = "") +
  theme_minimal(base_family = "calibri") +
  theme(panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        legend.text = element_text(size = 50))

ggsave('mapa1.png', plot = last_plot(), width = 10, height = 5, bg = 'white')

# North and Northeast
mapa2 <- mapa %>%
  filter(name_region %in% c("North", "Northeast"))

# Map
ggplot(mapa2) +
  geom_sf(aes(fill = `Descrição Seção`), color = "white", size  = 0.2) +
  labs(fill  = "") +
  theme_minimal(base_family = "calibri") +
  theme(panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        legend.text = element_text(size = 50))

ggsave('mapa2.png', plot = last_plot(), width = 10, height = 5, bg = 'white')

## 6TH EXERCISE - GRAPH OF MAIN PRODUCTS - ISIC ----

# Importing data
produto <- read_excel('comercio produto - ISIC.xlsx') %>%
  select(-c(Países, `Código ISIC Seção`))

# Pivoting
produto_pivot <- produto %>%
  pivot_longer(cols = -`Descrição ISIC Seção`,
               names_to = "Ano", values_to = "Valor") %>%
  mutate(Valor = Valor / 10^9,
         Ano = as.numeric(str_remove(Ano, " - Valor US\\$ FOB$")),
         `Descrição ISIC Seção` = case_when(
           `Descrição ISIC Seção` == "Agropecuária" ~ "Agriculture",
           `Descrição ISIC Seção` == "Indústria de Transformação" ~ "Manufacturing Industry",
           `Descrição ISIC Seção` == "Indústria Extrativa" ~ "Extractive Industry",
           `Descrição ISIC Seção` == "Outros Produtos" ~ "Other Products",
           T ~ `Descrição ISIC Seção`))

# Graph
ggplot(produto_pivot, aes(x = Ano, y = Valor, color = `Descrição ISIC Seção`)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  labs(x = "",
       y = "Export value (US$ billion)",
       color = "") +
  theme_minimal(base_family = "calibri") +
  theme(axis.text = element_text(size = 45),
        axis.title = element_text(size = 50),
        legend.text = element_text(size = 50))

ggsave(plot = last_plot(), file = "produto - ISIC.png", width = 10, height = 5, bg = 'white')

## 7TH EXERCISE - BRAZIL V. USA ----

# Importing data
export <- read_excel('export.xlsx')
import <- read_excel('import.xlsx')
gdp <- read_excel('gdp.xls')

# Droping some observations
gdp[gdp == "World"] <- NA
gdp[gdp == "East Asia & Pacific"] <- NA
gdp[gdp == "Europe & Central Asia"] <- NA
gdp[gdp == "Latin America & Caribbean"] <- NA
gdp[gdp == "North America"] <- NA
gdp[gdp == "Middle East & North Africa"] <- NA
gdp[gdp == "South Asia"] <- NA
gdp[gdp == "Sub-Saharan Africa"] <- NA
gdp <- na.omit(gdp)

# Changing the name of some countries
gdp %<>%
  mutate(Country = replace(Country, Country == 'Brunei Darussalam', 'Brunei'),
         Country = replace( Country, Country == 'Czechia', 'Czech Republic'),
         Country = replace(Country, Country == 'Hong Kong SAR, China', 'Hong Kong, China'),
         Country = replace(Country, Country == 'Timor-Leste', 'East Timor'),
         Country = replace(Country, Country == 'Turkiye', 'Turkey'),
         Country = replace(Country, Country == 'Viet Nam', 'Vietnam'))

export %<>%
  mutate(Country = replace(Country, Country == 'Ethiopia(excludes Eritrea)', 'Ethiopia'),
         Country = replace(Country, Country == 'Serbia, FR(Serbia/Montenegro)', 'Serbia'))

import %<>%
  mutate(Country = replace(Country, Country == 'Ethiopia(excludes Eritrea)', 'Ethiopia'),
         Country = replace(Country, Country == 'Serbia, FR(Serbia/Montenegro)', 'Serbia'))

## Imports from USA

# Calculating the fraction of US imports in the countries' GDP
base_ex <- left_join(export, gdp, by = 'Country') %>%
  arrange(desc(gdp)) %>%
  head(30) %>%
  mutate(valor_ex = Export/gdp*100) %>%
  select(Country, valor_ex)

# Calculating the fraction of countries' imports in US GDP
gdp_USA <- gdp %>%
  filter(Country == "United States") %>%
  pull(gdp)

base_im <- import %>%
  mutate(valor_im = Import/gdp_USA*100) %>%
  select(-Import)

# Joining the dataframes
base_M <- left_join(base_ex, base_im, by = 'Country')

base_M %<>%
  mutate(leverage_M = if_else(valor_ex > valor_im, 1, 0),
         diferença_M = valor_ex - valor_im)

# Graph of the import channel
ggplot(base_M, aes(x = valor_ex, y = valor_im)) +
  geom_point(color = "steelblue") +
  geom_point(data = subset(base_M, Country == "China"), aes(x = valor_ex, y = valor_im),
             color = "red", size = 2) +
  geom_point(data = subset(base_M, Country == "Russian Federation"), aes(x = valor_ex, y = valor_im),
             color = "red", size = 2) +
  geom_point(data = subset(base_M, Country == "Brazil"), aes(x = valor_ex, y = valor_im),
             color = "darkgreen", size = 2) +
  geom_text(data = subset(base_M, Country == "China"),
            aes(x = valor_ex, y = valor_im + .4, label = "China"), color = "black", size = 8) +
  geom_text(data = subset(base_M, Country == "Russian Federation"),
            aes(x = valor_ex + .4, y = valor_im + 1.3, label = "Russia"), color = "black", size = 8) +
  geom_segment(data = subset(base_M, Country == "Russian Federation"),
               aes(x = valor_ex + .3, y = valor_im + 1.1, xend = valor_ex + .05, yend = valor_im + .2),
               arrow = arrow(type = "closed", length = unit(0.06, "inches")) , color = "black") +
  geom_text(data = subset(base_M, Country == "Brazil"),
            aes(x = valor_ex + 1.1, y = valor_im + 1.2, label = "Brazil"), color = "black", size = 8) +
  geom_segment(data = subset(base_M, Country == "Brazil"),
               aes(x = valor_ex + 1, y = valor_im + 1, xend = valor_ex + .14, yend = valor_im + .14),
               arrow = arrow(type = "closed", length = unit(0.06, "inches")) , color = "black") +
  geom_abline(slope = 1, intercept = 0, color = "black", linetype = "dashed") +
  scale_x_continuous(limits = c(0, 16)) +
  scale_y_continuous(limits = c(0, 16)) +
  geom_segment(aes(x = 5, y = 5, xend = 5, yend = 7),
               arrow = arrow(type = "closed", length = unit(0.1, "inches")), color = "black") +
  geom_segment(aes(x = 6, y = 6, xend = 6, yend = 4),
               arrow = arrow(type = "closed", length = unit(0.1, "inches")), color = "black") +
  annotate("text", x = 3.3, y = 8, label = "Greater power", hjust = 0, size = 10) +
  annotate("text", x = 3.3, y = 7.4, label = "for the country", hjust = 0, size = 10) +
  annotate("text", x = 4.5, y = 3.7, label = "Greater power", hjust = 0, size = 10) +
  annotate("text", x = 5, y = 3.1, label = "for the US", hjust = 0, size = 10) +
  labs(x = "Country imports from US / GDP of the country (%)",
       y = "US imports from the country / US GDP (%)") +
  theme_minimal(base_family = "calibri") +
  theme(axis.title = element_text(size = 40),
        axis.text = element_text(size = 35))

ggsave(plot = last_plot(), file = "gráfico_M.png", width = 5, height = 5, bg = 'white')

## Exports of USA

# Calculating the fraction of exports to the US in the countries' GDP
base_ex_1 <- left_join(import, gdp, by = 'Country') %>%
  arrange(desc(gdp)) %>%
  head(30) %>%
  mutate(valor_ex = Import/gdp*100) %>%
  select(Country, valor_ex)

# Calculating the fraction of US exports to countries in US GDP
base_ex_2 <- export %>%
  mutate(valor_ex_2 = Export/gdp_USA*100) %>%
  select(-Export)

# Joining the dataframes
base_X <- left_join(base_ex_1, base_ex_2, by = 'Country')

base_X %<>%
  mutate(leverage_X = if_else(valor_ex > valor_ex_2, 1, 0),
         diferença_X = valor_ex - valor_ex_2)

# Graph of the export channel
ggplot(base_X, aes(x = valor_ex, y = valor_ex_2)) +
  geom_point(color = "steelblue") +
  geom_point(data = subset(base_M, Country == "Brazil"), aes(x = valor_ex, y = valor_im),
             color = "darkgreen", size = 2) +
  geom_text(data = subset(base_M, Country == "Brazil"),
            aes(x = valor_ex, y = valor_im + .4, label = "Brazil"), color = "black", size = 8) +
  geom_abline(slope = 1, intercept = 0, color = "black", linetype = "dashed") +
  scale_x_continuous(limits = c(0, 16)) +
  scale_y_continuous(limits = c(0, 16)) +
  geom_segment(aes(x = 5, y = 5, xend = 5, yend = 7),
               arrow = arrow(type = "closed", length = unit(0.1, "inches")), color = "black") +
  geom_segment(aes(x = 6, y = 6, xend = 6, yend = 4),
               arrow = arrow(type = "closed", length = unit(0.1, "inches")), color = "black") +
  annotate("text", x = 3.3, y = 8, label = "Greater power", hjust = 0, size = 10) +
  annotate("text", x = 3.3, y = 7.4, label = "for the country", hjust = 0, size = 10) +
  annotate("text", x = 4.5, y = 3.7, label = "Greater power", hjust = 0, size = 10) +
  annotate("text", x = 5, y = 3.1, label = "for the US", hjust = 0, size = 10) +
  labs(x = "Exports from the country to the US / GDP of the country (%)",
       y = "Exports from the US to the country / US GDP (%)") +
  theme_minimal(base_family = "calibri") +
  theme(axis.title = element_text(size = 40),
        axis.text = element_text(size = 35))

ggsave(plot = last_plot(), file = "gráfico_X.png", width = 5, height = 5, bg = 'white')

## Imports + Exports

# Joining and arranging the data
base <- inner_join(base_M, base_X, by = 'Country') %>%
  select(Country, diferença_M, diferença_X) %>%
  mutate(soma = diferença_M + diferença_X)

base <- left_join(base, gdp, by = 'Country') %>%
  arrange(desc(gdp)) %>%
  select(Country, soma)

# Selecting specific countries for the graph
base$fill_color <- ifelse(base$Country == "Brazil", "Brazil",
                          ifelse(base$Country == "China", "China", "Outros"))

# Graph
ggplot(base, aes(x = reorder(Country, -soma),
                 y = soma, fill = fill_color)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("Brazil" = "darkgreen", 
                               "China" = "red", 
                               "Outros" = "steelblue")) +
  labs(y = "Difference (p.p.)", x = "") +
  theme_minimal(base_family = "calibri") +
  theme(legend.position = "none",
        axis.title = element_text(size = 50),
        axis.text.x = element_text(angle = 45, hjust = 1, size = 40),
        axis.text.y = element_text(size = 40),
        plot.title = element_text(hjust = 0.5))

ggsave(plot = last_plot(), file = "Brazil v. USA - agregado.png", width = 10, height = 5, bg = 'white')

## 8TH EXERCISE - SUBSTITUTES ----

# Importing data
base <- read.csv('country_partner_hsproduct6digit_year_2017.csv', header = T, sep = ',')

head(base)

## Power of Brazil before USA

# Chunk to calculate equation (5)

import_USA_Brazil <- base %>%
  filter(location_name_short_en == 'United States of America',
         partner_name_short_en == 'Brazil') %>%
  mutate(net_import = import_value - export_value) %>%
  filter(net_import > 0)

import_USA_world <- base %>%
  filter(location_name_short_en == 'United States of America') %>%
  mutate(net_import = import_value - export_value) %>%
  filter(net_import > 0) %>%
  group_by(hs_product_code) %>%
  summarize(net_import_1 = sum(net_import))

import_USA <- left_join(import_USA_Brazil, import_USA_world, by = 'hs_product_code') %>%
  mutate(share = net_import / net_import_1) %>%
  select(hs_product_code, hs_product_name_short_en, share, net_import)

length(unique(import_USA$hs_product_code))

product <- import_USA %>%
  select(hs_product_code, hs_product_name_short_en)

import_USA_graph <- import_USA %>%
  arrange(desc(share)) %>%
  head(10)

# Graph
ggplot(import_USA_graph, aes(x = reorder(hs_product_name_short_en, share), y = share)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(x = "", 
       y = "Share") +
  theme_minimal(base_family = "calibri") +
  theme(axis.text = element_text(size = 45),
        axis.title = element_text(size = 50))

ggsave(plot = last_plot(), file = "import_USA.png", width = 10, height = 5, bg = 'white')

# Chunk to calculate equation (6)

import_total <- base %>%
  mutate(net_import = import_value - export_value) %>%
  filter(net_import > 0) %>%
  group_by(hs_product_code) %>%
  summarize(net_import_1 = sum(net_import)) %>%
  right_join(product, by = 'hs_product_code')

import_total_Brazil <- base %>%
  mutate(net_import = import_value - export_value) %>%
  filter(net_import > 0,
         partner_name_short_en == 'Brazil') %>%
  group_by(hs_product_code) %>%
  summarize(net_import_2 = sum(net_import)) %>%
  right_join(product, by = 'hs_product_code')

share_Brazil <- inner_join(import_total_Brazil, import_total, by = 'hs_product_code') %>%
  mutate(share_Brazil = net_import_2 / net_import_1)

share_Brazil_graph <- share_Brazil %>%
  arrange(desc(share_Brazil)) %>%
  head(10)

# Graph
ggplot(share_Brazil_graph, aes(x = reorder(hs_product_name_short_en.x, share_Brazil), y = share_Brazil)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  scale_y_continuous(limits = c(0,1),
                     labels = percent_format(accuracy = 1)) +
  labs(x = "", 
       y = "Share") +
  theme_minimal(base_family = "calibri") +
  theme(axis.text = element_text(size = 45),
        axis.title = element_text(size = 50))

ggsave(plot = last_plot(), file = "share_Brazil.png", width = 10, height = 5, bg = 'white')

# Index

final_1 <- left_join(import_USA, share_Brazil, by = 'hs_product_code') %>%
  mutate(index = share * share_Brazil * 100) %>%
  select(hs_product_name_short_en, share, share_Brazil, index)

final_1_graph <- final_1 %>%
  arrange(desc(index)) %>%
  head(10)

# Graph
ggplot(final_1_graph, aes(x = reorder(hs_product_name_short_en, index), y = index)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  scale_y_continuous(limits = c(0,100)) +
  labs(x = "", 
       y = "Index") +
  theme_minimal(base_family = "calibri") +
  theme(axis.text = element_text(size = 45),
        axis.title = element_text(size = 50))

ggsave(plot = last_plot(), file = "index.png", width = 10, height = 5, bg = 'white')

power_Brazil <- mean(final_1$index)

## Power of USA before Brazil

# Chunk to calculate equation (5)

import_Brazil_USA <- base %>%
  filter(location_name_short_en == 'Brazil',
         partner_name_short_en == 'United States of America') %>%
  mutate(net_import = import_value - export_value) %>%
  filter(net_import > 0)

import_Brazil_world <- base %>%
  filter(location_name_short_en == 'Brazil') %>%
  mutate(net_import = import_value - export_value) %>%
  filter(net_import > 0) %>%
  group_by(hs_product_code) %>%
  summarize(net_import_1 = sum(net_import))

import_Brazil <- left_join(import_Brazil_USA, import_Brazil_world, by = 'hs_product_code') %>%
  mutate(share = net_import / net_import_1) %>%
  select(hs_product_code, hs_product_name_short_en, share, net_import)

length(unique(import_Brazil$hs_product_code))

product <- import_Brazil %>%
  select(hs_product_code, hs_product_name_short_en)

# Chunk to calculate equation (6)

import_total <- base %>%
  mutate(net_import = import_value - export_value) %>%
  filter(net_import > 0) %>%
  group_by(hs_product_code) %>%
  summarize(net_import_1 = sum(net_import)) %>%
  right_join(product, by = 'hs_product_code')

import_total_USA <- base %>%
  mutate(net_import = import_value - export_value) %>%
  filter(net_import > 0,
         partner_name_short_en == 'United States of America') %>%
  group_by(hs_product_code) %>%
  summarize(net_import_2 = sum(net_import)) %>%
  right_join(product, by = 'hs_product_code')

share_USA <- inner_join(import_total_USA, import_total, by = 'hs_product_code') %>%
  mutate(share_USA = net_import_2 / net_import_1)

# Index

final_USA <- left_join(import_Brazil, share_USA, by = 'hs_product_code') %>%
  mutate(index = share * share_USA * 100) %>%
  select(hs_product_name_short_en, share, share_USA, index)

power_USA <- mean(final_USA$index)

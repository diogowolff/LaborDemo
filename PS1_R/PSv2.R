library("dplyr")
library("ggplot2")
library("mvtnorm")

#######################
###  DATA CLEANING  ###
#######################

dataRaw <- read.csv("small_dataset.csv")

priceIndex <- read.csv("median_consumer_price_index.csv") %>%
  rename("PRICEINDEX" = "MEDCPIM094SFRBCLE") %>%
  mutate(YEAR = as.integer(format(as.Date(DATE),"%Y"))) %>%
  select(-DATE) %>%
  group_by(YEAR) %>%
  summarise(PRICEINDEX = mean(PRICEINDEX)) %>%
  mutate(PRICEINDEX = PRICEINDEX/PRICEINDEX[1])


# Function for cleaning values
filter_out <- function(x, cols = everything(), value) {
  filter(x, if_all(cols, ~ !(.x == value)))
}

nominalValues <- c("HHINCOME", "INCTOT", "INCWAGE", "INCWELFR", "INCSS")

dataClean <- dataRaw %>%
  select(-c(SAMPLE, CBSERIAL, HHWT, CLUSTER, STRATA, GQ, PERNUM, PERWT, RACE, RACED)) %>%
  na.omit %>%
  filter_out(nominalValues, 9999999) %>%          # code for N/A is 9999999
  filter_out(c("EDUCD"), 001) %>%                 # code for N/A is 001
  filter_out(c("EDUCD"), 999) %>%                 # code for Missing is 999
  filter_out(c("EMPSTAT", "WKSWORK2"), 0) %>%     # code for N/A is 0
  filter_out(c("EMPSTATD", "UHRSWORK"), 00) %>%   # code for N/A is 00
  # filter_out(c("INCWAGE"), 999998) %>%            # code for Missing is 999998
  mutate(WKSWORK2 = ifelse(WKSWORK2 == 0, NA, (13*(2*WKSWORK2-1) + 1)/2)) %>%
  # mutate(YEAR = format(as.Date(paste0(as.character(SAMPLE), "01"), "%Y"))) %>%
  left_join(priceIndex) %>%
  group_by(YEAR) %>%
  mutate(across(nominalValues, ~ .x/PRICEINDEX))


rm(dataRaw)


###########################
###  KERNEL REGRESSION  ###
###########################

## Kernel

Z <- as.matrix(dataClean[,c("AGE", "NCHILD", "EDUCD")])
Z <- cbind("const" = rep(1, nrow(dataClean)), Z)

y <- 1*!(dataClean$EMPSTAT == 3)

# bandwidth
n <- nrow(Z)
d <- 3
sds <- apply(Z[,-1], 2, sd)
bws <- sds*(4/((d+2)*n))^(1/(d + 4))

# Functions
multiEpan <- function(x) {
  d = length(x)
  nx <- norm(as.matrix(x))
  return((d + 2)/(2*4/3*pi)*(1-nx^2)*(abs(nx) <= 1))
}


betaLL <- function(point, bws) {
  Zx <- sweep(Z, 2, c(0, point)) # bws
  Kx <- apply(Zx[,-1], 1, \(x) dmvnorm(x/bws))
  solve(t(Zx)%*%(Kx*Zx))%*%t(Zx)%*%(Kx*y)
}



## PLOTTING

default <- c(45, 1, 65)

### plot AGE

grid <- seq(min(dataClean$AGE), max(dataClean$AGE), by = 2)
grid <- grid[-c(1:3, (length(grid)-10):length(grid))]


values <- c()

for(x in grid) {
  values <- c(values, betaLL(c(x, default[-1]), bws)[2])
  print(x)
}

df <- data.frame("AGE" = values, "axis" = grid)

ggplot(df, aes(x = axis, y = AGE)) +
  geom_line() +
  ggtitle("Effect of AGE on P as a function of AGE", subtitle = "with NCHILD = 1 and EDUCD = 65 fixed")



### plot EDUCD

grid <- seq(min(dataClean$EDUCD), max(dataClean$EDUCD))
grid <- grid[-c(1:3, (length(grid)-3):length(grid))]


values <- c()

for(x in grid) {
  values <- c(values, betaLL(c(default[-3], x))[4])
}


educ <-  values*grid
df <- data.frame("EDUCD" = educ, "axis" = grid)

ggplot(df, aes(x = axis, y = EDUCD)) +
  geom_line() +
  ggtitle("Effect of EDUCD on P as a function of EDUCD", subtitle = "with AGE = 45 and NCHILD = 1 fixed")













### GARBAGE

for (x in nec) {
  plot(density(dataClean[,"URBAN"]))
}


nec <- c("HHINCOME", "METRO", "SPLOC", "SPRULE", "SFRELATE", "RELATE", "SEX", "AGE", "MARST", "NCHILD", "NCHLT5", "EDUC", "EMPSTAT", "UHRSWORK", "WKSWORK2", "INCTOT", "INCWAGE", "INCSS", "INCWELFR")
nomCol <- names(dataRaw)
nomCol[!(nomCol %in% nec)]

nec[!(nec %in% nomCol)]

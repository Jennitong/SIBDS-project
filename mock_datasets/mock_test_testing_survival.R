
#---- random, no relation
#dt <- read_csv("mock_data_no_association.csv")


#lrt_test(dt$genders, dt$outcome,dt$duration)

#lrt_test(dt$age, dt$outcome,dt$duration)

#---- associated, binary group
#time_adult <- rexp(50,1/10)
#time_child <- rexp(30, 1/5)
#succ_adult <- rbinom(n = 50, size = 1, prob = 0.9)
#succ_child <- rbinom(n = 30, size = 1, prob = 0.2)

#dt_2 <- data.frame(
#  time = as.double(c(time_adult, time_child)),
#  succ = c(succ_adult,succ_child),
#  age = c(rep("Adult",50), rep("Child",30))
#)

#dt_2 <- read_csv("mock_associated_binary.csv")

#lrt_test(dt_2$age, dt_2$succ,dt_2$time)

# --- associated, three-level group


#time_man <- rexp(50,1/10)
#time_woman <- rexp(30, 1/5)
#time_nonbinary <- rexp(20, 1/20)
#succ_man <- rbinom(n = 50, size = 1, prob = 0.9)
#succ_woman <- rbinom(n = 30, size = 1, prob = 0.2)
#succ_non_binary <- rbinom(n = 20, size = 1, prob = 0.01)

#dt_3 <- data.frame(
#  time = as.double(c(time_adult, time_child,time_nonbinary)),
#  succ = c(succ_adult,succ_child,succ_non_binary),
#  gender = c(rep("Adult",50), rep("Child",30), rep("Non Binary",20))
#)

#dt_3 <- read_csv("mock_associated_three.csv")

#lrt_test(dt_3$gender, dt_3$succ,dt_3$time)

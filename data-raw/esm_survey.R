# Build datasets from Neubauer & Schmiedek (2024) via openESM
#
# Paper: https://doi.org/10.1007/s11618-023-01182-8
# Data:  https://osf.io/bhq3p
# Codebook: https://osf.io/csfwg
# Code:  https://osf.io/84kdr/files
# License: CC-BY 4.0
#
# Requires: openesm package (NOT a package dependency — used only here)

d <- openesm::get_dataset("0062_neubauer")
df <- as.data.frame(d$data)

# --- Item groups (all 1-7 Likert) ---
emo_cols <- c("happy", "afraid", "sad", "balanced", "exhausted",
              "cheerful", "worried", "lively", "angry", "relaxed")
mot_cols <- c("study_motivation_others_disappointed",
              "study_motivation_felt_bad",
              "study_motivation_important",
              "study_motivation_interesting",
              "study_motivation_compulsory",
              "study_motivation_proving",
              "study_motivation_understanding",
              "study_motivation_enjoyment")
reg_cols <- c("see_good_in_bad", "focus_on_good", "suppression",
              "changed_feeling", "rumination")
eng_cols <- c("study_enjoy", "study_wearing_down", "study_satisfied",
              "study_difficult_reconcile", "study_interesting",
              "study_exhausted", "study_only_necessary", "study_energy",
              "study_identification", "study_expectations",
              "study_consider_quitting")

all_cols <- c(emo_cols, mot_cols, reg_cols, eng_cols)
sub <- df[, all_cols]
sub[sub == -1] <- NA   # -1 = "not applicable"

# Person-level means, rounded to integers
person_means <- aggregate(sub, by = list(id = df$id), FUN = function(x) {
  m <- mean(x, na.rm = TRUE)
  if (is.nan(m)) NA_real_ else as.integer(round(m))
})
person_means$id <- NULL
complete <- person_means[complete.cases(person_means), ]
rownames(complete) <- NULL

# --- ema_emotions: 10 emotions, clean names ---
ema_emotions <- complete[, seq_along(emo_cols)]
names(ema_emotions) <- c("Happy", "Afraid", "Sad", "Balanced", "Exhausted",
                          "Cheerful", "Worried", "Lively", "Angry", "Relaxed")

# --- student_survey: all 34 items, prefixed for faceting ---
student_survey <- complete
names(student_survey) <- c(
  "Emo_Happy", "Emo_Afraid", "Emo_Sad", "Emo_Balanced", "Emo_Exhausted",
  "Emo_Cheerful", "Emo_Worried", "Emo_Lively", "Emo_Angry", "Emo_Relaxed",
  "Mot_Disappointed", "Mot_FeltBad", "Mot_Important", "Mot_Interesting",
  "Mot_Compulsory", "Mot_Proving", "Mot_Understanding", "Mot_Enjoyment",
  "Reg_SeeGood", "Reg_FocusGood", "Reg_Suppression",
  "Reg_ChangedFeeling", "Reg_Rumination",
  "Eng_Enjoy", "Eng_WearingDown", "Eng_Satisfied",
  "Eng_DifficultReconcile", "Eng_Interesting", "Eng_Exhausted",
  "Eng_OnlyNecessary", "Eng_Energy", "Eng_Identification",
  "Eng_Expectations", "Eng_ConsiderQuitting"
)

# --- ema_beeps: beep-level sample for daily plots ---
esm_daily <- df[, c("id", "day", "start_time", "happy", "angry")]
esm_daily <- esm_daily[complete.cases(esm_daily), ]
set.seed(42)
idx <- sample(nrow(esm_daily), min(500, nrow(esm_daily)))
ema_beeps <- esm_daily[idx, ]
ema_beeps <- ema_beeps[order(ema_beeps$day, ema_beeps$start_time), ]
ema_beeps$day <- ema_beeps$day + 1L
rownames(ema_beeps) <- NULL

# --- Save ---
save(ema_emotions, file = "data/ema_emotions.rda", compress = "xz")
save(student_survey, file = "data/student_survey.rda", compress = "xz")
save(ema_beeps, file = "data/ema_beeps.rda", compress = "xz")

library BreastCancerScreeningsFHIR version '0.0.009'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include FHIRCommon version '4.0.1' called FC
include CQMCommon version '0.1.0' called Global
include QICoreElements version '4.1.0' called QICore
include SupplementalDataElementsFHIR4 version '2.0.000' called SDE
include AdultOutpatientEncountersFHIR4 version '2.2.000' called AdultOutpatientEncounters
//include AdvancedIllnessandFrailtyExclusionECQMFHIR4 version '5.17.000' called FrailtyLTI
//include PalliativeCareFHIR version '0.6.000' called PalliativeCare
//include CumulativeMedicationDurationFHIR4 version '1.0.000' called CMD
//include HospiceFHIR4 version '2.3.000' called Hospice

valueset "Bilateral Mastectomy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1005'
valueset "History of bilateral mastectomy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1068'
valueset "Left": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.122.12.1036'
valueset "Mammography": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.108.12.1018'
valueset "Online Assessments": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1089'
valueset "Right": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.122.12.1035'
valueset "Status Post Left Mastectomy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1069'
valueset "Status Post Right Mastectomy": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1070'
valueset "Telephone Visits": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1080'
valueset "Unilateral Mastectomy Left": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1133'
valueset "Unilateral Mastectomy Right": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1134'
valueset "Unilateral Mastectomy, Unspecified Laterality": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.198.12.1071'

parameter "Measurement Period" Interval<DateTime>
  default Interval[@2020-01-01T00:00:00.0, @2021-01-01T00:00:00.0)

context Patient

define "SDE Ethnicity":
  SDE."SDE Ethnicity"

define "SDE Payer":
  SDE."SDE Payer"

define "SDE Race":
  SDE."SDE Race"

define "SDE Sex":
  SDE."SDE Sex"

define "Denominator":
  "Initial Population"

// NOTE: Shouldn't this be checking for clinicalStatus at least, if not also verification status?
define "Right Mastectomy Diagnosis":
  ((QICore.Condition StatusPostRightMastectomy
      where StatusPostRightMastectomy.code in "Status Post Right Mastectomy"
    )
      union (QICore.Condition UnilateralMastectomy
          where UnilateralMastectomy.code in "Unilateral Mastectomy, Unspecified Laterality"
            and UnilateralMastectomy.bodySite in "Right"
      )
  ) RightMastectomy
    where RightMastectomy.prevalenceInterval() starts on or before end of "Measurement Period"

define "Right Mastectomy Procedure":
  QICore.ProcedurePerformed UnilateralMastectomyRightPerformed
    where UnilateralMastectomyRightPerformed.code in "Unilateral Mastectomy Right"
      and UnilateralMastectomyRightPerformed.performed.toInterval() ends on or before end of "Measurement Period"

define "Left Mastectomy Procedure":
  QICore.ProcedurePerformed UnilateralMastectomyLeftPerformed
    where UnilateralMastectomyLeftPerformed.code in "Unilateral Mastectomy Left"
      and UnilateralMastectomyLeftPerformed.performed.toInterval() ends on or before end of "Measurement Period"

define "Numerator":
  exists (
    QICore.Observation Mammogram
      where Mammogram.code in "Mammography"
        and Mammogram.effective.toInterval() ends 27 months or less on or before end of "Measurement Period"
  )

define "Telehealth Services":
  QICore.EncounterPerformed TelehealthEncounter
    where (TelehealthEncounter.type in "Online Assessments" or TelehealthEncounter.type in "Telephone Visits")
      and TelehealthEncounter.period.toInterval() during "Measurement Period"

define "Bilateral Mastectomy Procedure":
  QICore.ProcedurePerformed BilateralMastectomyPerformed
    where BilateralMastectomyPerformed.code in "Bilateral Mastectomy"
      and BilateralMastectomyPerformed.performed.toInterval() ends on or before end of "Measurement Period"

define "Bilateral Mastectomy Diagnosis":
  QICore.Condition BilateralMastectomyHistory
    where BilateralMastectomyHistory.code in "History of bilateral mastectomy"
      and BilateralMastectomyHistory.prevalenceInterval() starts on or before end of "Measurement Period"

define "Left Mastectomy Diagnosis":
  ((QICore.Condition StatusPostLeftMastectomy
    where StatusPostLeftMastectomy.code in "Status Post Left Mastectomy"
  )
    union (QICore.Condition UnilateralMastectomy
      where UnilateralMastectomy.code in "Unilateral Mastectomy, Unspecified Laterality"
        and UnilateralMastectomy.bodySite in "Left"
    )
  ) LeftMastectomy
    where LeftMastectomy.prevalenceInterval() starts on or before end of "Measurement Period"

define "Initial Population":
  AgeInYearsAt(date from start of "Measurement Period") in Interval[51, 74)
    and Patient.gender = 'female'
    and exists ( AdultOutpatientEncounters."Qualifying Encounters"
      union "Telehealth Services"
    )

/* TODO:
define "Denominator Exclusions":
  ( Hospice."Has Hospice"
    or ( ( exists "Right Mastectomy Diagnosis"
          or exists "Right Mastectomy Procedure"
      )
        and ( exists "Left Mastectomy Diagnosis"
            or exists "Left Mastectomy Procedure"
        )
    )
    or exists "Bilateral Mastectomy Diagnosis"
    or exists "Bilateral Mastectomy Procedure"
    or ( FrailtyLTI."Advanced Illness and Frailty Exclusion Not Including Over Age 80" )
    or ( AgeInYearsAt(date from start of "Measurement Period")>= 65
        and FrailtyLTI."Has Long Term Care Periods Longer Than 90 Consecutive Days"
    )
    or PalliativeCare."Palliative Care in the Measurement Period"
  )
*/

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
  ((QICore.Condition Condition
      where Condition.code in "Status Post Right Mastectomy"
    )
      union (QICore.Condition Condition
          where Condition.code in "Unilateral Mastectomy, Unspecified Laterality"
            and Condition.bodySite in "Right"
      )
  ) RightMastectomy
    where RightMastectomy.prevalenceInterval() starts on or before end of "Measurement Period"

define "Right Mastectomy Procedure":
  QICore.ProcedurePerformed Procedure
    where Procedure.code in "Unilateral Mastectomy Right"
      and Procedure.performed.toInterval() ends on or before end of "Measurement Period"

define "Left Mastectomy Procedure":
  QICore.ProcedurePerformed Procedure
    where Procedure.code in "Unilateral Mastectomy Left"
      and Procedure.performed.toInterval() ends on or before end of "Measurement Period"

define "Numerator":
  exists (
    QICore.Observation Observation
      where Observation.code in "Mammography"
        and Observation.effective.toInterval() ends 27 months or less on or before end of "Measurement Period"
  )

define "Telehealth Services":
  QICore.EncounterPerformed Encounter
    where (Encounter.type in "Online Assessments" or Encounter.type in "Telephone Visits")
      and Encounter.period.toInterval() during "Measurement Period"

define "Bilateral Mastectomy Procedure":
  QICore.ProcedurePerformed Procedure
    where Procedure.code in "Bilateral Mastectomy"
      and Procedure.performed.toInterval() ends on or before end of "Measurement Period"

define "Bilateral Mastectomy Diagnosis":
  QICore.Condition Condition
    where Condition.code in "History of bilateral mastectomy"
      and Condition.prevalenceInterval() starts on or before end of "Measurement Period"

define "Left Mastectomy Diagnosis":
  ((QICore.Condition Condition
    where Condition.code in "Status Post Left Mastectomy"
  )
    union (QICore.Condition Condition
      where Condition.code in "Unilateral Mastectomy, Unspecified Laterality"
        and Condition.bodySite in "Left"
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

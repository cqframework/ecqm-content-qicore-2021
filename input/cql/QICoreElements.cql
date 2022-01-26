library QICoreElements version '4.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon version '4.0.1' called FC

context Patient

/* Extensions */

define fluent function isElective(serviceRequest ServiceRequest):
  FC.ModifierExtension(serviceRequest, 'http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-isElective').value as boolean

define fluent function procedure(encounter Encounter):
  (FC.Extensions(encounter, 'http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter-procedure')) E
    return {
      type: FC.Extension(E, 'type').value as CodeableConcept,
      rank: FC.Extension(E, 'rank').value as positiveInt,
      procedure: FC.Extension(E, 'procedure').value as Reference
    }

define fluent function doNotPerformReason(requestResource DomainResource):
  FC.Extension(requestResource, 'http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-doNotPerformReason').value as CodeableConcept

define fluent function recorded(domainResource DomainResource):
  FC.Extension(domainResource, 'http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-recorded').value as dateTime

define fluent function notDone(eventResource DomainResource):
  FC.ModifierExtension(eventResource, 'http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-notDone').value as boolean

define fluent function notDoneReason(eventResource DomainResource):
  FC.Extension(eventResource, 'http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-notDoneReason').value as CodeableConcept

define fluent function presentOnAdmission(element Element):
  FC.Extension(element, 'http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter-diagnosisPresentOnAdmission').value as CodeableConcept

/* Elements */

// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-coverage
define Coverage:
  [Coverage]

// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-condition
define Condition:
  [Condition]

// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-encounter
define Encounter:
  [Encounter]

define EncounterFinished:
  Encounter E
    where E.status = 'finished'

// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-medicationrequest
define MedicationRequest:
  [MedicationRequest] R
    where R.status in { 'active', 'on-hold', 'completed', 'draft' }
      and R.doNotPerform is not true

/*
define "Antithrombotic Therapy at Discharge":
  ["MedicationRequest": medication in "Antithrombotic Therapy"] Antithrombotic
    where exists (Antithrombotic.category C where FHIRHelpers.ToConcept(C) in { Global."Community", Global."Discharge" })
      and Antithrombotic.status in { 'active', 'completed' }
      and Antithrombotic.intent.value = 'order'

define "Antithrombotic Therapy at Discharge":
  QICore.MedicationRequest Antithrombotic
    where Antithrombotic.medication in "Antithrombotic Therapy"
      and (Antithrombotic.isCommunity() or Antithrombotic.isDischarge())
      and Antithrombotic.status in { 'active', 'completed' }
      and Antithrombotic.intent = 'order'

define "Antithrombotic Therapy at Discharge":
  [MedicationRequest: medication in "Antithrombotic Therapy"] Antithrombotic
    where (Antithrombotic.isCommunity() or Antithrombotic.isDischarge())
      and Antithrombotic.status in { 'active', 'completed' }
      and Antithrombotic.intent = 'order'
*/

// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-mednotrequested
define MedicationNotRequested:
  [MedicationRequest] R
    where R.status = 'completed'
      and R.doNotPerform is true

/*
define "Antithrombotic Not Given at Discharge":
  ["MedicationRequest": medication in "Antithrombotic Therapy"] NoAntithromboticDischarge
    where NoAntithromboticDischarge.doNotPerform is true
			and (NoAntithromboticDischarge.reasonCode in "Medical Reason"
				or NoAntithromboticDischarge.reasonCode in "Patient Refusal")
      and exists (NoAntithromboticDischarge.category C where FHIRHelpers.ToConcept(C) ~ FC."Community" or FHIRHelpers.ToConcept(C) ~ FC."Discharge")
      and NoAntithromboticDischarge.status = 'completed'
      and NoAntithromboticDischarge.intent = 'order'

define "Antithrombotic Not Given at Discharge":
  QICore.MedicationNotRequested NoAntithromboticDischarge
    where NoAntithromboticDischarge.medication in "Antithrombotic Therapy"
      and (NoAntithromboticDischarge.reasonCode in "Medical Reason"
        or NoAntithromboticDischarge.reasonCode in "Patient Refusal")
      and (NoAntithromboticDischarge.isCommunity() or NoAntithromboticDischarge.isDischarge())
      and NoAntithromboticDischarge.intent = 'order'

define "Antithrombotic Not Given at Discharge":
  ["MedicationNotRequested": medication in "Antithrombotic Therapy"] NoAntithromboticDischarge
    where (NoAntithromboticDischarge.reasonCode in "Medical Reason"
        or NoAntithromboticDischarge.reasonCode in "Patient Refusal")
      and (NoAntithromboticDischarge.isCommunity() or NoAntithromboticDischarge.isDischarge())
      and NoAntithromboticDischarge.intent = 'order'
*/

// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-observation
define Observation:
  [Observation] O
    where O.status in { 'final', 'amended', 'corrected' }

// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-observationnotdone
define ObservationNotDone:
  [Observation] O
    where O.status = 'cancelled'

// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-procedure
define Procedure:
  [Procedure] P
    where P.status in { 'preparation', 'in-progress', 'on-hold', 'completed' }

define ProcedureCompleted:
  Procedure P
    where P.status = 'completed'

/*
define "Flexible Sigmoidoscopy Performed":
 [Procedure: "Flexible Sigmoidoscopy"] FlexibleSigmoidoscopy
	 where FlexibleSigmoidoscopy.status = 'completed'
		 and Global."Normalize Interval"(FlexibleSigmoidoscopy.performed) ends 5 years or less on or before end of "Measurement Period"

define "Flexible Sigmoidoscopy Performed":
  QICore.ProcedurePerformed FlexibleSigmoidoscopy
    where FlexibleSigmoidoscopy.code in "Flexible Sigmoidoscopy"
      and FlexibleSigmoidoscopy.performed.toInterval() ends 5 years or less on or before end of "Measurement Period"
*/

// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-procedurenotdone
define ProcedureNotDone:
  [Procedure] P
    where P.status = 'not-done'

/*
define "No VTE Prophylaxis Device Applied":
  ["Procedure": "Device Application"] DeviceApplied
    let DeviceNotDoneTiming: Global.GetExtension(DeviceApplied, 'qicore-recorded').value
    where (DeviceApplied.usedCode in "Intermittent pneumatic compression devices (IPC)"
      or DeviceApplied.usedCode in "Venous foot pumps (VFP)"
      or DeviceApplied.usedCode in "Graduated compression stockings (GCS)"
    )
      and  DeviceApplied.status = 'not-done'
    return {id: DeviceApplied.id, requestStatusReason: DeviceApplied.statusReason, authoredOn: DeviceNotDoneTiming}

define "No VTE Prophylaxis Device Applied":
  QICore.ProcedureNotDone DeviceApplied
    where DeviceApplied.code in "Device Application"
      and (DeviceApplied.usedCode in "Intermittent pneumatic compression devices (IPC)"
        or DeviceApplied.usedCode in "Venous foot pumps (VFP)"
        or DeviceApplied.usedCode in "Graduated compression stockings (GCS)")
    return {
      id: DeviceApplied.id,
      requestStatusReason: DeviceApplied.statusReason,
      authoredOn: DeviceApplied.recorded()
    }

*/

// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-servicerequest
define ServiceRequest:
  [ServiceRequest] SR
    where SR.status in { 'draft', 'active', 'on-hold', 'completed' }
      and SR.doNotPerform is not true

/*
define "Intervention Comfort Measures":
  (["ServiceRequest": "Comfort Measures"] P
    where P.intent = 'order'
  )
    union (["Procedure": "Comfort Measures"] InterventionPerformed
      where InterventionPerformed.status in {'completed', 'in-progress'}
    )

define "Intervention Comfort Measures":
  (QICore.ServiceRequest SR
    where SR.code in "Comfort Measures"
      and SR.intent = 'order'
  )
    union (
      QICore.Procedure InterventionPerformed
        where InterventionPerformed.code in "Comfort Measures"
          and InterventionPerformed.status in { 'completed', 'in-progress' }
    )
*/

// @profile: http://hl7.org/fhir/us/qicore/StructureDefinition/qicore-servicenotrequested
define ServiceNotRequested:
  [ServiceRequest] SR
    where SR.status = 'completed'
      and SR.doNotPerform is true

/*
define "No VTE Prophylaxis Device Order":
  (["ServiceRequest": "Venous foot pumps (VFP)"]
    union ["ServiceRequest": "Intermittent pneumatic compression devices (IPC)"]
    union ["ServiceRequest": "Graduated compression stockings (GCS)"]
  ) DeviceOrder
    where DeviceOrder.status = 'completed'
      and DeviceOrder.doNotPerform is true

define "No VTE Prophylaxis Device Order":
  QICore.ServiceNotRequested DeviceOrder
    where DeviceOrder.code in "Venous foot pumps (VFP)"
      or DeviceOrder.code in "Intermittent pneumatic compression devices (IPC)"
      or DeviceOrder.code in "Graduated compression stockings (GCS)"
*/

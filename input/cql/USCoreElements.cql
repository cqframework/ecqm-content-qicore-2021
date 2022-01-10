library USCoreElements version '3.1.1'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include FHIRCommon version '4.0.1' called FC

context Patient

define fluent function ethnicity(patient Patient):
  patient P
    let ethnicityEx: FC.Extension(P, 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity')
    return
      {
        ombCategory: FC.Extension(ethnicityEx, 'ombCategory').value as Coding,
        detailed:
          (FC.Extensions(ethnicityEx, 'detailed')) E
            return E.value as Coding,
        text: FC.Extension(ethnicityEx, 'text').value as string
      }

define fluent function race(patient Patient):
  patient P
    let raceEx: FC.Extension(P, 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-race')
    return
      {
        ombCategory:
          (FC.Extensions(raceEx, 'ombCategory')) E
            return E.value as Coding,
        detailed:
          (FC.Extensions(raceEx, 'detailed')) E
            return E.value as Coding,
        text: FC.Extension(raceEx, 'text').value as string
      }

define fluent function birthsex(patient Patient):
  FC.Extension(patient, 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex').value as code

define fluent function direct(contactPoint ContactPoint):
  FC.Extension(contactPoint, 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-direct').value as boolean

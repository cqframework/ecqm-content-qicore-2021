library AdultOutpatientEncountersFHIR4 version '2.2.000'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include QICoreElements version '4.1.0' called QICore

include CQMCommon version '0.1.0' called Global

valueset "Annual Wellness Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.1240'
valueset "Home Healthcare Services": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1016'
valueset "Office Visit": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "Preventive Care Services - Established Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1025'
valueset "Preventive Care Services-Initial Office Visit, 18 and Up": 'http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.101.12.1023'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Qualifying Encounters":
  QICore.EncounterFinished E
    where (E.type in "Office Visit"
        or E.type in "Annual Wellness Visit"
        or E.type in "Preventive Care Services - Established Office Visit, 18 and Up"
        or E.type in "Preventive Care Services-Initial Office Visit, 18 and Up"
        or E.type in "Home Healthcare Services"
      )
      and E.period.toInterval() during "Measurement Period"

/*
define "Qualifying Encounters":
  ([Encounter: "Office Visit"]
  		union [Encounter: "Annual Wellness Visit"]
  		union [Encounter: "Preventive Care Services - Established Office Visit, 18 and Up"]
  		union [Encounter: "Preventive Care Services-Initial Office Visit, 18 and Up"]
  		union [Encounter: "Home Healthcare Services"]
  ) ValidEncounter
		where ValidEncounter.status  = 'finished'
		and Global."Normalize Interval"(ValidEncounter.period) during "Measurement Period"
*/

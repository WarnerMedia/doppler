package receive

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"

	"doppler/internal/web"
	"doppler/pkg/log"

	"github.com/google/uuid"
	"github.com/hashicorp/go-version"
)

// Event represents registration as well as telemetry data that comes in over http
type Event struct {

	//required for standard call
	WMUKID string `json:"wmukid"`

	//required for external, optional for standard
	AppID string `json:"appId,omitempty"`

	//required for external call only
	UserID string `json:"userId,omitempty"`

	//optional for standard call
	Brand            string `json:"brand,omitempty"`
	SubBrand         string `json:"subBrand,omitempty"`
	Platform         string `json:"platform,omitempty"`
	ClientResolvedIP string `json:"clientResolvedIp,omitempty"`
	CompanyName      string `json:"companyName,omitempty"`
	EventID          string `json:"eventId,omitempty"`
	EventName        string `json:"eventName,omitempty"`
	EventTimestamp   string `json:"eventTimestamp,omitempty"`
	EventType        string `json:"eventType,omitempty"`
	ProductName      string `json:"productName,omitempty"`
	SentAtTimestamp  string `json:"sentAtTimestamp,omitempty"`
	HHIDVersion      int64  `json:"hhidVersion,omitempty"`

	IDs                  map[string]interface{} `json:"ids,omitempty"`
	Session              map[string]interface{} `json:"session,omitempty"`
	Library              map[string]interface{} `json:"library,omitempty"`
	Location             map[string]interface{} `json:"location,omitempty"`
	NavigationProperties map[string]interface{} `json:"navigationProperties,omitempty"`
	EventProperties      map[string]interface{} `json:"eventProperties,omitempty"`
	ConsentProperties    map[string]interface{} `json:"consentProperties,omitempty"`
	Device               map[string]interface{} `json:"device,omitempty"`
	ContentMetadata      map[string]interface{} `json:"contentMetadata,omitempty"`
	AdsProperties        map[string]interface{} `json:"adsProperties,omitempty"`
	NetworkProperties    map[string]interface{} `json:"networkProperties,omitempty"`
	HTTPMessages         map[string]interface{} `json:"httpMessages,omitempty"`
}

type outbound struct {
	Warnings []string `json:"warnings,omitempty"`
}

// Validate returns the first schema validation error encountered; nil if valid
func (in Event) Validate(env string) error {
	env = strings.ToLower(env)

	if in.WMUKID == "" {
		return fmt.Errorf("missing required fields %q", "wmukid")
	}
	if !strings.Contains(env, "prod") && !isUuidValid(in.WMUKID) {
		return fmt.Errorf("invalid UUID: %q", "wmukid")
	}

	return nil
}

//Appends warning messages to a slice if optional fields are missing or malformed
func (in Event) ValidateOptionalFields() outbound {
	var optionalElementWarnings []string

	brandErr := in.isBrandValid()
	if brandErr != nil {
		optionalElementWarnings = append(optionalElementWarnings, brandErr.Error())
	}

	platformErr := in.isPlatformValid()
	if platformErr != nil {
		optionalElementWarnings = append(optionalElementWarnings, platformErr.Error())
	}

	subBrandErr := in.isSubBrandValid()
	if subBrandErr != nil {
		optionalElementWarnings = append(optionalElementWarnings, subBrandErr.Error())
	}

	uspStringErr := in.isUspStringValid()
	if uspStringErr != nil {
		optionalElementWarnings = append(optionalElementWarnings, uspStringErr.Error())
	}

	cdpIdErr := in.isCdpIdValid()
	if cdpIdErr != nil {
		optionalElementWarnings = append(optionalElementWarnings, cdpIdErr.Error())
	}

	eventNameErr := in.isEventNameValid()
	if eventNameErr != nil {
		optionalElementWarnings = append(optionalElementWarnings, eventNameErr.Error())
	}

	eventTypeErr := in.isEventTypeValid()
	if eventTypeErr != nil {
		optionalElementWarnings = append(optionalElementWarnings, eventTypeErr.Error())
	}

	countryErr := in.isCountryValid()
	if countryErr != nil {
		optionalElementWarnings = append(optionalElementWarnings, countryErr.Error())
	}

	return outbound{optionalElementWarnings}
}

//Validates if Brand is present and valid.
func (in Event) isBrandValid() error {
	if len(in.Brand) > 0 {
		return nil
	}
	return fmt.Errorf("missing optional field: %s", "brand")
}

//Validates if Platform is present and valid.
func (in Event) isPlatformValid() error {
	if len(in.Platform) > 0 {
		return nil
	}
	return fmt.Errorf("missing optional field: %s", "platform")
}

//Validates if SubBrand is present and valid if the library.version is >= 2.1.0.
func (in Event) isSubBrandValid() error {
	if val, ok := in.Library["version"]; ok {
		userProvidedVersion := fmt.Sprintf("%v", val)
		if len(userProvidedVersion) > 0 {
			v1, _ := version.NewVersion(userProvidedVersion)
			v2, _ := version.NewVersion("2.1.0")
			//only check for subBrand if the version is >= than 2.1.0
			if !v1.LessThan(v2) {
				if len(in.SubBrand) == 0 {
					return fmt.Errorf("missing optional field: %s", "subBrand")
				}
			}

		} else {
			return nil
		}
	}
	return nil
}

//Validates if the Country is present in the payload.
func (in Event) isCountryValid() error {
	if val, ok := in.Location["country"]; ok {
		countryIsoCode := fmt.Sprintf("%v", val)
		if len(countryIsoCode) == 2 {
			return nil
		} else if val != "" && len(countryIsoCode) != 2 {
			return fmt.Errorf("invalid optional field: %s: %w", "country", errors.New("must be ISO-2 code of the country"))
		}
	}
	return fmt.Errorf("missing optional field: %s", "country")
}

//Validates if the given Event Name is an acceptable event name. If not, it will add an appropriate warning to the optionalElementWarnings slice.
func (in Event) isEventNameValid() error {
	if len(in.EventName) == 0 {
		return fmt.Errorf("missing optional field: %s", "eventName")
	}
	switch in.EventName {
	case "inbrain impression", "consent update", "identity on page complete", "inbrain click",
		"identity on page start", "heartbeat", "v1.identity", "v1.telemetry", "Inbrain Impression":
		return nil
	default:
		return fmt.Errorf("invalid optional field: %s", "eventName")
	}
}

//Validates if the Event Type is either telemetry, identity or privacy. If not, it will add an appropriate warning to the optionalElementWarnings slice.
func (in Event) isEventTypeValid() error {
	switch in.EventType {
	case "telemetry", "identity", "privacy", "v1.identity", "v1.telemetry":
		return nil
	default:
		if len(in.EventType) > 0 {
			return fmt.Errorf("invalid optional field: %s", "eventType")
		} else {
			return fmt.Errorf("missing optional field: %s", "eventType")
		}
	}
}

//Validates if USP String is present and has a length of 4 characters.
func (in Event) isUspStringValid() error {
	if val, ok := in.ConsentProperties["uspString"]; ok {
		strUspString := fmt.Sprintf("%v", val)
		if len(strUspString) > 0 {
			return nil
		}
	}
	return fmt.Errorf("missing optional field: %s", "uspstring")
}

//Validates if CDP ID is present and the UUIDv4 valid.
func (in Event) isCdpIdValid() error {
	if val, ok := in.IDs["cdpid"]; ok {
		strCdpId := fmt.Sprintf("%v", val)
		if isUuidValid(strCdpId) {
			return nil
		} else {
			err := errors.New("invalid UUID for optional field: cdpid")
			return err
		}
	}
	return nil
}

//Checks if a UUID is valid.
func isUuidValid(u string) bool {
	_, err := uuid.Parse(u)
	return err == nil
}

// Validate returns the first schema validation error encountered; nil if valid.
func (in Event) ValidateExternal() error {
	if in.UserID == "" {
		return fmt.Errorf("missing required field %s", "userId")
	}

	if in.AppID == "" {
		return fmt.Errorf("missing required field %s", "appId")
	}

	return nil
}

// KinesisInbound represents an Event record that is sent to kinesis
type KinesisInbound struct {
	Event

	//populated by us, not sent by clients
	ReceivedAtTimestamp int64  `json:"receivedAtTimestamp"`
	SourceIPAddress     string `json:"sourceIpAddress"`
	ServerEventId       string `json:"serverEventId"`
}

// GetIP - Get the X-FORWARDED-FOR ip address
func GetIP(r *http.Request) string {
	forwarded := r.Header.Get("X-FORWARDED-FOR")
	if forwarded != "" {
		return forwarded
	}
	return r.RemoteAddr
}

func PrepareKinesisRecord(httpIn Event, ipAddress string, log *log.Logger) ([]byte, *web.Response) {
	kinesisIn := KinesisInbound{
		Event: httpIn,
	}

	//record timestamp
	kinesisIn.ReceivedAtTimestamp = time.Now().Unix()
	kinesisIn.SourceIPAddress = ipAddress
	kinesisIn.ServerEventId = uuid.New().String()

	//marshal into json for kinesis
	kinesisBits, err := json.Marshal(kinesisIn)
	if err != nil {
		log.Warn("error in marshalling struct to json", err)
		return nil, web.Empty(http.StatusBadRequest)
	}

	return kinesisBits, nil
}

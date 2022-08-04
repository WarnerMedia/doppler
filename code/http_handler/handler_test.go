package main

import (
	"doppler/internal/v2/receive"
	"doppler/pkg/log"
	"encoding/json"
	"testing"
)

func init() {
	logger = log.New()
}

func TestReceiveValidReq(t *testing.T) {
	bitsIn := []byte(`{"appId":"test-app-id","brand":"","clientResolvedIp":"127.0.0.1","companyName":"Example","device":{"type":""},"eventId":"00000000-0000-0000-0000-000000000000","eventName":"identity on page start","eventProperties":{"cookies":{},"featureFlagValues":{}},"eventTimestamp":"2020-01-01T09:09:09.000Z","eventType":"identity","library":{"initConfig":{},"name":"","version":"1.0.0"},"location":{"city":"ATLANTA","country":"US","language":"en","locale":"en-US","state":"GA","timezone":"UTC","zip":"30315"},"navigationProperties":{"path":"/","referrer":"","rootDomain":"","search":"","title":"","url":"http://localhost/"},"productName":"","sentAtTimestamp":"2020-01-01T09:09:09.000Z","wmukid":"00000000-0000-0000-0000-000000000000"}`)
	var httpIn receive.Event
	err := json.Unmarshal(bitsIn, &httpIn)
	if err != nil {
		t.Errorf("Unable to unmarshall buffer: got %v", err)
	}

	bitsOut, err := json.Marshal(httpIn)
	if err != nil {
		t.Errorf("Unable to marshall buffer: got %v", err)
	}

	if len(string(bitsIn)) != len(string(bitsOut)) {
		t.Errorf("bitsIn not equal to bitsOut")
	}

}

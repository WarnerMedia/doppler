package sqs

import (
	"errors"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/sqs"
	"github.com/aws/aws-sdk-go/service/sqs/sqsiface"
)

var attempts int

type mockSuccessSQS struct {
	sqsiface.SQSAPI
}

type mockFailureSQS struct {
	sqsiface.SQSAPI
}

func (m mockSuccessSQS) SendMessage(in *sqs.SendMessageInput) (*sqs.SendMessageOutput, error) {
	attempts++
	return &sqs.SendMessageOutput{}, nil
}

func (m mockFailureSQS) SendMessage(in *sqs.SendMessageInput) (*sqs.SendMessageOutput, error) {
	defer func() { attempts++ }()
	if attempts == 0 {
		return nil, errors.New("Go back to Kinesis!")
	}
	return &sqs.SendMessageOutput{}, nil
}

func TestSendMessageSuccess(t *testing.T) {
	attempts = 0
	s := &SQS{
		sqs:      mockSuccessSQS{},
		queueUrl: aws.String("test"),
	}
	err := s.SendMessage("test message")
	if err != nil {
		t.Error("Expected nil, got", err)
	}
	if attempts != 1 {
		t.Error("Expected 1 attempt, got", attempts)
	}
}

func TestSendMessageFailure(t *testing.T) {
	attempts = 0
	s := &SQS{
		sqs:      mockFailureSQS{},
		queueUrl: aws.String("test"),
	}
	err := s.SendMessage("test message")
	if err != nil {
		t.Error("Expected nil, got", err)
	}
	if attempts != 2 {
		t.Error("Expected 2 attempts, got", attempts)
	}
}

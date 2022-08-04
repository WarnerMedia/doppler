package sqs

import (
	"context"
	"errors"
	"fmt"
	"log"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
	"github.com/aws/aws-sdk-go/service/sqs/sqsiface"
	"github.com/cenkalti/backoff"
)

var (
	ErrNilSQSSvc    = errors.New("SQS handler cannot be nil")
	MaxReceiveCount = aws.Int64(10)
	WaitTimeSeconds = aws.Int64(20)
)

type SQS struct {
	sqs      sqsiface.SQSAPI // safe to use concurrently
	queueUrl *string
}

// New initializes a new SQS client instance.
func New(url string) *SQS {
	s := session.Must(session.NewSession())
	return &SQS{
		sqs:      sqs.New(s),
		queueUrl: aws.String(url),
	}
}

// SendMessage publishes a new message to the SQS queue,
// retrying with exponential backoff if errors are encountered.
func (c *SQS) SendMessage(message string) error {
	if c.sqs == nil {
		return ErrNilSQSSvc
	}

	input := sqs.SendMessageInput{
		MessageBody: aws.String(message),
		QueueUrl:    c.queueUrl,
	}
	f := func() error {
		_, err := c.sqs.SendMessage(&input)
		return err
	}
	// Retry for a maximum of 4 minutes
	b := backoff.NewExponentialBackOff()
	b.MaxElapsedTime = 4 * time.Minute
	return backoff.Retry(f, b)
}

// ProcessSQS continuously reads from the configured queue and applies
// a given mapping function to each retrieved message
func (c *SQS) ProcessSQS(ctx context.Context, f func(string) error) error {
	if c.sqs == nil {
		return ErrNilSQSSvc
	}

	receiveMessageInput := &sqs.ReceiveMessageInput{
		MaxNumberOfMessages: MaxReceiveCount,
		QueueUrl:            c.queueUrl,
		WaitTimeSeconds:     WaitTimeSeconds,
	}

	err := receiveMessageInput.Validate()
	if err != nil {
		return err
	}

	for {
		output, err := c.sqs.ReceiveMessageWithContext(ctx, receiveMessageInput)
		if err != nil {
			return err
		}

		if len(output.Messages) == 0 {
			continue
		}

		err = c.processBatch(ctx, output, f)
		if err != nil {
			return err
		}
	}

	return nil
}

func (c *SQS) processBatch(ctx context.Context, batch *sqs.ReceiveMessageOutput, f func(string) error) (err error) {
	var receiptHandles []*sqs.DeleteMessageBatchRequestEntry
	defer func() {
		if len(receiptHandles) == 0 {
			return
		}

		err := c.deleteSQSMessages(ctx, receiptHandles)
		if err != nil {
			log.Println("Error in deleting the messages", batch, err)
		}
	}()

	for _, message := range batch.Messages {
		receiptHandles = append(receiptHandles, &sqs.DeleteMessageBatchRequestEntry{
			Id:            message.MessageId,
			ReceiptHandle: message.ReceiptHandle,
		})

		// apply map function
		err = f(*message.Body)
		if err != nil {
			log.Printf("error mapping sqs message: %v", err)
		}
	}

	return nil
}

// deleteSQSMessages deletes messages in batches which can reduce the cost by 10x
func (c *SQS) deleteSQSMessages(ctx context.Context, receiptHandles []*sqs.DeleteMessageBatchRequestEntry) error {
	deleteOutput, err := c.sqs.DeleteMessageBatchWithContext(ctx, &sqs.DeleteMessageBatchInput{
		QueueUrl: c.queueUrl,
		Entries:  receiptHandles,
	})

	if err != nil {
		return fmt.Errorf("error in deleting the messages from SQS %w", err)
	}

	if len(deleteOutput.Failed) != 0 {
		return fmt.Errorf("failed to delete %d message from queue."+
			" Failed Messages: %v", len(deleteOutput.Failed), deleteOutput.Failed)
	}

	return nil
}

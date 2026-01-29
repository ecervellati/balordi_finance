package main

import (
	"bytes"
	"encoding/csv"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"sync"
)

type Transaction struct {
	From   string `json:"from"`
	To     string `json:"to"`
	Amount int    `json:"amount"`
}

var baseURL string

func init() {
	baseURL = os.Getenv("API_URL")
	if baseURL == "" {
		baseURL = "http://localhost:4005"
	}

	fmt.Printf("Configuration loaded: API URL -> %s\n", baseURL)
}

func main() {
	const numJobs = 100
	const numWorkers = 10

	jobs := make(chan Transaction, numJobs)
	var wg sync.WaitGroup

	for w := 1; w <= numWorkers; w++ {
		wg.Add(1)
		go worker(w, jobs, &wg)
	}
	var records = readCsvFile("C:\\Users\\edok1\\Desktop\\transactions.csv")
	for _, record := range records {
		amount, _ := strconv.Atoi(record[2])
		jobs <- Transaction{From: record[0], To: record[1], Amount: amount}
	}

	close(jobs)
	wg.Wait()
	fmt.Println("All transactions are processed")
}

func worker(id int, jobs <-chan Transaction, wg *sync.WaitGroup) {
	defer wg.Done()
	client := &http.Client{}

	for t := range jobs {
		jsonData, _ := json.Marshal(t)
		resp, err := client.Post(fmt.Sprintf("%s/transfer", baseURL), "application/json", bytes.NewBuffer(jsonData))

		if err != nil {
			fmt.Printf("Worker %d: Errore -> %v\n", id, err)
			continue
		}

		fmt.Printf("Worker %d: Inviato bonifico, Status: %d\n", id, resp.StatusCode)
		resp.Body.Close()
	}
}

func readCsvFile(filePath string) [][]string {
	f, err := os.Open(filePath)
	if err != nil {
		log.Fatal("Unable to read input file "+filePath, err)
	}
	defer f.Close()

	csvReader := csv.NewReader(f)
	if _, err = csvReader.Read(); err != nil {
		log.Fatal("Error reading CSV header  "+filePath, err)
	}

	records, err := csvReader.ReadAll()
	if err != nil {
		log.Fatal("Unable to parse file as CSV for "+filePath, err)
	}

	return records
}

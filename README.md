# Proof of Attendance
The idea comes from the hackathon of Invisible Garden.

We use zkp to verify the attendance for each participant.

# Technical Architecture
The technical architecture is as follows:

![technical architecture](./docs/technical_architecture.png)

# usage

## 1. install dependencies
```
yarn 
```

## 2. compile the circuit and setup verification process
```
./setup.sh
```
all the files will be generated in the build folder.

### 3. start the nfc-device-simulator and server
```
cd nfc-device-simulator
yarn start
```

```
cd ../server
go run main.go
```

### 4. interact with the nfc-device-simulator to generate the proof
```
./tap-nfc-generate-proof.sh
```

### 5. verify the proof and record the attendance
```
./verify-and-record.sh
```



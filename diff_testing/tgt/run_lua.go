package main

import (
	"fmt"
	"os"
	"github.com/yuin/gopher-lua"
	// "/root/go/src/github.com/yuin/gopher-lua"
)

func main() {
	fmt.Println("ENV_VAR:", os.Getenv("GOPHER_TARGET"))

	L := lua.NewState()
	defer L.Close()
	if err := L.DoFile(os.Getenv("GOPHER_TARGET")); err != nil {
			panic(err)
	}
}

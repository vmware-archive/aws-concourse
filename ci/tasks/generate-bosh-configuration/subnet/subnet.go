package subnet

import (
	"fmt"
	"strconv"
	"strings"
)

type Subnet struct {
	Octets [4]int
	Mask   int
}

func ParseSubnet(s string) (Subnet, error) {
	parts := strings.Split(s, "/")
	if len(parts) != 2 {
		return Subnet{}, fmt.Errorf("subnet %q could not be parsed", s)
	}

	mask, err := strconv.Atoi(parts[1])
	if err != nil {
		return Subnet{}, fmt.Errorf("subnet mask %q could not be parsed: %s", parts[1], err)
	}

	octetParts := strings.Split(parts[0], ".")
	if len(octetParts) != 4 {
		return Subnet{}, fmt.Errorf("subnet octets %q could not be parsed", parts[0])
	}

	var octets [4]int
	for i, part := range octetParts {
		var err error
		octets[i], err = strconv.Atoi(part)
		if err != nil {
			return Subnet{}, fmt.Errorf("subnet octet %q could not be parsed: %s", part, err)
		}
	}

	return Subnet{
		Octets: octets,
		Mask:   mask,
	}, nil
}

func (s Subnet) Range(start, end int) (string, error) {
	if start < 0 {
		return "", fmt.Errorf("subnet range start \"%d\" cannot be negative", start)
	}

	if end > 256 {
		return "", fmt.Errorf("subnet range end \"%d\" cannot exceed 256", end)
	}

	if start > end {
		return "", fmt.Errorf("subnet range start \"%d\" cannot exceed subnet range end \"%d\"", start, end)
	}

	return fmt.Sprintf("%d.%d.%d.%d-%d.%d.%d.%d",
		s.Octets[0],
		s.Octets[1],
		s.Octets[2],
		start,
		s.Octets[0],
		s.Octets[1],
		s.Octets[2],
		end), nil
}

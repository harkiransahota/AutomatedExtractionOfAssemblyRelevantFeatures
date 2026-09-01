# Automated Extraction of Assembly-Relevant Features from Mesh-Based CAD Models

This repository contains the accompanying code for the paper:

**"Extraction of Assembly-Relevant Features from Mesh-Based CAD Models for Rule-Based Assembly Planning"**

---

## Overview

This project presents a pipeline for the automated extraction of assembly-relevant features from mesh-based CAD models and the subsequent derivation of assembly knowledge.

The approach combines geometric analysis with symbolic reasoning to enable the generation of structured assembly instructions directly from 3D mesh data.

---

## Pipeline

The implemented pipeline consists of the following steps:

1. **Fastener Detection**
   - Identification of fasteners such as screws, nuts, and washers.

2. **Local Feature Extraction**
   - Extraction of geometric features for non-fastener parts, including:
     - Cylindrical features (holes and bosses)
     - Surface features

3. **Connection Detection**
   - Matching of features to identify connections between parts:
     - Screw-based connections (fastener–cylinder matching)
     - Glue connections (surface mating analysis)

4. **Manual Feature Extension**
   - Optional enrichment of the dataset with manually defined connections
     (e.g. glue connections that cannot be derived from geometry alone)

5. **Predicate-Based Reasoning**
   - Translation of features and connections into ASP facts
   - Derivation of assembly operations using the Clingo reasoner and a predefined rule base

---

## Example

An example workflow is provided using the `UseCaseToyCar` dataset:

- Load assembly meshes
- Perform feature extraction (fasteners, cylinders, surfaces)
- Detect screw connections via feature matching
- Add glue connections manually and detect mating surfaces
- Generate structured assembly operations through ASP reasoning

---

## Output

The pipeline produces:

- Extracted geometric features:
  - Fasteners
  - Cylinders (holes and bosses)
  - Surface regions
- Detected connections:
  - Screw connections
  - Glue connections
- Derived assembly operations:
  - Insert, tighten, apply glue, and related steps

---

## Requirements

- Python 3.x
- `trimesh`
- `numpy`
- `matplotlib` (optional for visualization)
- `clingo` (for ASP reasoning)

---

## Notes

- The system operates on **mesh-based CAD models (e.g., STL files)**.
- All geometric thresholds are defined relative to mesh scale to ensure robustness across differently sized models.
- Interactive UI-based selection is not included; part selection is handled programmatically.

---

## Citation

If you use this repository or any part of the accompanying code or rule base in your research, please cite:

> Harkiran Sahota and Adam Kłodowski.  
> *Automated Extraction of Assembly-Relevant Features from Mesh-Based CAD Models for Rule-Based Assembly Planning.*  
> Journal of Intelligent Manufacturing (under review), 2026.

---

## License
MIT

# Variable-Precision Approximate BFloat16 Multiplier

This repository contains a Verilog RTL implementation of a **variable-precision approximate floating-point multiplier**, inspired by the work of Hao Zhang and Seok-Bum Ko:

> H. Zhang and S.-B. Ko,  
> *"Variable-Precision Approximate Floating-Point Multiplier for Efficient Deep Learning Computation,"*  
> IEEE Transactions on Circuits and Systems II: Express Briefs, vol. 69, no. 5, pp. 2503–2507, May 2022.  
> doi: https://doi.org/10.1109/TCSII.2022.3161005

---

## 📌 Background

Deep learning accelerators increasingly rely on **reduced precision arithmetic** (such as FP16 or BFloat16) to improve efficiency. However, standard BFloat16 multipliers still consume significant hardware resources and power.

This design implements the **variable-precision approximate multiplier** concept introduced in the cited paper. The key insight is:

- The distribution of activations/weights in neural networks often follows a **normal distribution**.
- Not all values require the same precision:
  - **Small exponents** → use **higher mantissa precision** (to maintain accuracy).  
  - **Large exponents** → use **lower mantissa precision** (approximation has less effect).  
- By truncating mantissa bits depending on the exponent magnitude, we can **reduce area and power** while maintaining nearly the same model accuracy.

According to the paper, this approach achieves up to:
- **19% area reduction**
- **42% power reduction**
compared to a conventional BFloat16 multiplier.

---

## 🧩 Architecture

The RTL implements the following stages:

1. **Input Processing (`inp_processing`)**  
   - Splits BFloat16 inputs into sign, exponent, and mantissa.  
   - Adds the hidden leading `1` to mantissas.

2. **Precision Control (`precision_ctl`)**  
   - Uses the product exponent magnitude to decide how many mantissa bits should be **kept or truncated**.  
   - Implements a **masking mechanism** for dynamic precision scaling.

3. **Sign & Exponent Processing (`sgn_exp_processing`)**  
   - Computes the product sign (`Sa ^ Sb`).  
   - Adds exponents and subtracts bias (127).

4. **Mantissa Multiplication (`mantissa_multiplier`)**  
   - Performs mantissa multiplication using **Radix-4 Booth encoding**.  
   - Uses a **Carry-Save Adder (CSA) tree** to reduce partial products efficiently.  
   - Applies the precision mask to truncate products.

5. **Carry-Propagation Addition (`carry_prop_adder`)**  
   - Finalizes the mantissa sum from CSA results.

6. **Normalization (`normalization`)**  
   - Normalizes mantissa if overflow occurs.  
   - Adjusts the exponent accordingly.

7. **Exception Handling (`exception_handling`)**  
   - Handles special cases: overflow, underflow.  
   - Formats the final BFloat16 result (`{sign, exponent, mantissa}`).


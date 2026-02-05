# Contributing to BitBlaster 10-Bit Processor

Thank you for your interest in contributing to this project! This is an academic project primarily maintained as a portfolio piece, but improvements and suggestions are welcome.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. **Check existing issues** to avoid duplicates
2. **Open a new issue** with:
   - Clear, descriptive title
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Your environment (Quartus version, OS, DE10-Lite board revision)
   - Relevant screenshots or waveforms

### Suggesting Enhancements

For feature requests or enhancements:

1. **Open an issue** tagged with `enhancement`
2. Explain:
   - What problem does it solve?
   - How would it work?
   - Is it backward compatible?
   - Any hardware implications?

### Submitting Pull Requests

We welcome pull requests for:
- Bug fixes
- Documentation improvements
- Code quality improvements
- New features (discuss in an issue first)

**Process:**

1. **Fork** the repository
2. **Create a branch** from `main`
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
   - Follow existing code style
   - Add comments for complex logic
   - Update documentation if needed
4. **Test thoroughly**
   - Compile successfully in Quartus
   - Test on DE10-Lite hardware (if applicable)
   - Verify no timing violations
5. **Commit** with clear messages
   ```bash
   git commit -m "Brief description of change
   
   Longer explanation of what changed and why.
   Fixes #123"
   ```
6. **Push** to your fork
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Open a Pull Request** on GitHub
   - Reference related issues
   - Describe changes and motivation
   - Include test results

## Code Style Guidelines

### SystemVerilog Style

**Naming Conventions:**
- Modules: `lowercase_with_underscores` (e.g., `register_file`)
- Signals: `Capitalized_With_Underscores` (e.g., `Data_Bus`, `Enable_Signal`)
- Parameters: `UPPERCASE` (e.g., `ADD`, `LOAD`)
- File names: Match module name with `.sv` extension

**Formatting:**
- **Indentation**: 4 spaces (no tabs)
- **Line length**: Aim for <100 characters
- **Spacing**: Space after commas, around operators
- **Comments**: Explain why, not what
  ```systemverilog
  // Good: Explains intent
  Ain = 1;  // Latch first operand for multi-cycle operation
  
  // Bad: Describes code
  Ain = 1;  // Set Ain to 1
  ```

**Module Structure:**
```systemverilog
// File header with author, date, description
// Module declaration
module module_name (
    input  logic [9:0] input_signal,
    output logic [9:0] output_signal
);

// Parameter declarations
parameter CONSTANT = value;

// Internal signal declarations
logic [9:0] internal_signal;

// Always blocks (sequential then combinational)
always_ff @(negedge clk) begin
    // Sequential logic
end

always_comb begin
    // Combinational logic
end

endmodule
```

### Documentation Style

**Markdown:**
- Use headers hierarchically (# → ## → ###)
- Code blocks with language hints: \`\`\`systemverilog
- Tables for structured data
- Links to source files for verification

**Comments:**
- Use `//` for single-line comments
- Use `/* */` for multi-line explanations
- Add section headers with `//!` or `//___`
- Document all module interfaces

## Testing Requirements

### Before Submitting

- [ ] Code compiles without errors in Quartus
- [ ] No critical warnings introduced
- [ ] Timing analysis passes (if applicable)
- [ ] Tested on actual DE10-Lite hardware (recommended)
- [ ] Documentation updated (README, ARCHITECTURE, DEVELOPMENT)
- [ ] Commit messages are clear and descriptive

### Testing on Hardware

If your change affects functionality:
1. Program FPGA with your modified design
2. Run manual test cases (see DEVELOPMENT.md)
3. Document test results in PR description
4. Include photos/videos if behavior changed

## Project Scope

### In Scope

✅ Bug fixes in existing modules
✅ Performance optimizations
✅ Documentation improvements
✅ Code quality/readability improvements
✅ Minor feature additions that don't change ISA

### Out of Scope (Discuss First)

⚠️ ISA changes (adding/removing/modifying instructions)
⚠️ Major architectural changes (bus width, register count)
⚠️ Hardware changes (different FPGA boards)
⚠️ Adding external dependencies

## Architecture Decisions

This project follows specific design choices for educational purposes:

- **10-bit width**: Matches DE10-Lite I/O
- **4 registers**: Simplified for learning
- **Shared bus**: Demonstrates arbitration
- **4-cycle execution**: Clear pipeline stages
- **Negative-edge clocking**: Timing clarity

If you want to change these fundamentals, open an issue for discussion first.

## License

By contributing, you agree that your contributions will be licensed under the GPL-3.0 License, the same license as this project.

## Questions?

- 💬 Open a GitHub Discussion for general questions
- 🐛 Open an Issue for bugs or feature requests
- 📧 Contact maintainers for sensitive topics

---

## Acknowledgments

Contributors will be acknowledged in:
- README.md Credits section
- Git commit history
- GitHub contributors list

Thank you for helping make this project better!

/// <reference types="cypress" />

describe("Localhost React App E2E", () => {
  beforeEach(() => {
    // 로컬 개발 서버 접속
    cy.visit("http://localhost:3000");
  });

  it("displays default todos from Backend", () => {
    // Backend에서 가져온 기본 데이터 2개 확인
    cy.get(".todo-list li").should("have.length", 2);
    cy.get(".todo-list li").first().should("contain.text", "Pay electric bill");
    cy.get(".todo-list li").last().should("contain.text", "Walk the dog");
  });

  it("can add a new todo item", () => {
    const newItem = "Feed the cat";

    // 입력 후 Enter
    cy.get("[data-test=new-todo]").type(`${newItem}{enter}`);

    // 리스트에 반영 확인
    cy.get(".todo-list li")
      .should("have.length", 3)
      .last()
      .should("have.text", newItem);
  });

  it("can mark a todo as completed", () => {
    cy.contains("Pay electric bill")
      .parent()
      .find("input[type=checkbox]")
      .check();

    cy.contains("Pay electric bill")
      .parents("li")
      .should("have.class", "completed");
  });

  context("with a checked task", () => {
    beforeEach(() => {
      cy.contains("Pay electric bill")
        .parent()
        .find("input[type=checkbox]")
        .check();
    });

    it("can filter for active tasks", () => {
      cy.contains("Active").click();
      cy.get(".todo-list li")
        .should("have.length", 1)
        .first()
        .should("have.text", "Walk the dog");

      cy.contains("Pay electric bill").should("not.exist");
    });

    it("can filter for completed tasks", () => {
      cy.contains("Completed").click();
      cy.get(".todo-list li")
        .should("have.length", 1)
        .first()
        .should("have.text", "Pay electric bill");

      cy.contains("Walk the dog").should("not.exist");
    });

    it("can clear completed tasks", () => {
      cy.contains("Clear completed").click();

      cy.get(".todo-list li")
        .should("have.length", 1)
        .should("not.have.text", "Pay electric bill");

      cy.contains("Clear completed").should("not.exist");
    });
  });
});

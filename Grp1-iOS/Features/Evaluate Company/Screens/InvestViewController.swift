//
//  InvestViewController.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 12/02/26.
//

import UIKit

final class InvestViewController: UIViewController {
    
 
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    
       var puzzle: DailyPuzzle!
       private var selectedCompanyId: String?

       override func viewDidLoad() {
           super.viewDidLoad()
           view.backgroundColor = .systemBackground
           setupTable()
           styleSubmitButton()
       }

       private func setupTable() {
           tableView.dataSource = self
           tableView.delegate = self
           tableView.tableFooterView = UIView()
           tableView.separatorStyle = .none
                tableView.backgroundColor = .clear
       }
    
    
    private func styleSubmitButton() {
        submitButton.layer.cornerRadius = 24
        submitButton.clipsToBounds = true
    }

       @IBAction func didTapSubmit(_ sender: UIButton) {
           guard let selectedCompanyId else {
               let alert = UIAlertController(
                   title: "No Company Selected",
                   message: "Please select a company before proceeding.",
                   preferredStyle: .alert
               )
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               present(alert, animated: true)
               return
           }

           performSegue(withIdentifier: "showResult", sender: selectedCompanyId)
       }

       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "showResult",
              let vc = segue.destination as? ResultViewController {
               vc.selectedCompanyId = sender as? String
               vc.puzzle = puzzle
           }
       }
   }

   extension InvestViewController: UITableViewDataSource, UITableViewDelegate {

       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           puzzle.companies.count
       }

       func tableView(_ tableView: UITableView,
                      cellForRowAt indexPath: IndexPath) -> UITableViewCell {

           guard let cell = tableView.dequeueReusableCell(
                   withIdentifier: "CompanySelectCell",
                   for: indexPath
               ) as? CompanySelectCell else {
                   return UITableViewCell()
               }

           let company = puzzle.companies[indexPath.row]
           let isSelected = selectedCompanyId == company.id
           cell.configure(company: company, isSelected: isSelected)
           return cell
       }

       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           let company = puzzle.companies[indexPath.row]

           if selectedCompanyId == company.id {
               selectedCompanyId = nil   // deselect
           } else {
               selectedCompanyId = company.id
           }

           tableView.reloadData()
       }
       
       func tableView(_ tableView: UITableView,
                          heightForRowAt indexPath: IndexPath) -> CGFloat {
               return 90   // gives space for capsule UI
           }
   }

import pandas as pd


def main():
    # print("Create the first mock data.")
    df = pd.DataFrame()

    df["first_name"] = ["James", "Amy", "Jay", "Michael"]
    df["middle_name"] = ["", "M", "J", ""]
    df["last_name"] = ["Jiang", "Wu", "Phil", "Cooper"]
    df["confirmation_number"] = ["ABC123", "DEF456", "GHI123", "JKL456"]
    df["flight"] = ["NB1234", "SB4321", "NB4321", "SB1234"]
    df["flightDate"] = ["2022-05-20", "2022-05-19", "2022-05-18", "2022-05-17"]
    df["ticket_price"] = [567, 678, 890, 123]
    df.to_csv("mock_data/mock_flight_data.csv", index=False)

    df_2 = pd.DataFrame()
    df_2["first_name"] = ["James", "Cindy", "Lion", "Zebra"]
    df_2["middle_name"] = ["", "H", "G", ""]
    df_2["last_name"] = ["Jiang", "Xu", "Pasta", "Rock"]
    df_2["confirmation_number"] = ["ABC123", "DEF456", "GHI123", "JKL456"]
    df_2["flight"] = ["NB1234", "SB4321", "NB4321", "SB1234"]
    df_2["flightDate"] = ["2022-05-20", "2022-05-19", "2022-05-18", "2022-05-17"]
    df_2["ticket_price"] = [567, 678, 890, 123]

    df_2.to_csv("mock_data/mock_flight_data_2.csv", index=False)

    df_3 = pd.DataFrame()
    df_3["first_name"] = ["James", "Cindy", "Lion", "Zebra"]
    df_3["middle_name"] = ["", "H", "G", ""]
    df_3["last_name"] = ["Jiang", "Xu", "Pasta", "Rock"]
    df_3["confirmation_number"] = ["ABC123", "DEF456", "GHI123", "JKL456"]
    df_3["flight"] = ["NB1234", "SB4321", "NB4321", "SB1234"]
    df_3["flightDate"] = ["2022-05-16", "2022-05-19", "2022-05-18", "2022-05-17"]
    df_3["ticket_price"] = [567, 678, 890, 123]
    df_3.to_csv("mock_data/mock_flight_data_3.csv", index=False)
